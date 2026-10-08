import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/comercios_providers.dart';
import '../../../../core/error/fallo.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_piedras.dart';
import '../../domain/entities/alta.dart';
import '../../domain/reglas/reglas_alta.dart';
import '../providers/alta_providers.dart';
import '../widgets/letrero.dart';
import '../widgets/preguntas_alta.dart';

/// Pedir el registro del negocio desde el celular como una conversación (HU-03-01): una
/// pregunta por pantalla y, al final, el letrero. VECI revisa la solicitud antes de crear
/// el negocio; mientras tanto la persona sigue siendo cliente (ADR-0019).
class AltaNegocioPage extends ConsumerStatefulWidget {
  const AltaNegocioPage({super.key});

  @override
  ConsumerState<AltaNegocioPage> createState() => _AltaNegocioPageState();
}

class _AltaNegocioPageState extends ConsumerState<AltaNegocioPage> {
  var _indice = 0;
  var _borrador = const BorradorAlta();
  String? _problema;
  var _ocupado = false;
  var _enviada = false;

  PasoAlta get _paso => PasoAlta.values[_indice];
  bool get _ultimo => _indice == PasoAlta.values.length - 1;

  void _cambiar(BorradorAlta nuevo) => setState(() => _borrador = nuevo);

  void _seguir() {
    final falta = problemaEnPaso(_paso, _borrador);
    setState(() {
      _problema = falta;
      if (falta == null) _indice++;
    });
  }

  Future<void> _solicitar() async {
    setState(() {
      _ocupado = true;
      _problema = null;
    });
    try {
      await ref.read(comerciosRepositoryProvider).solicitar(_borrador);
      ref.invalidate(misSolicitudesProvider);
      if (mounted) setState(() => _enviada = true);
    } on Object catch (error) {
      if (mounted) setState(() => _problema = _mensaje(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  static String _mensaje(Object error) => switch (error) {
    SinConexion() => 'Para enviar la solicitud necesitas internet. Lo escrito no se pierde.',
    PeticionRechazada(:final mensaje) => mensaje,
    _ => 'No pudimos enviar tu solicitud. Intenta otra vez en un momento.',
  };

  @override
  Widget build(BuildContext context) {
    if (_enviada) return _SolicitudEnviada(nombre: _borrador.nombre.trim());
    final catalogos = ref.watch(catalogosAltaProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar el registro de mi negocio')),
      body: ListView(
        padding: const EdgeInsets.all(VeciEspacio.l),
        children: [
          PiedrasDelCamino(total: PasoAlta.values.length, actual: _indice),
          const SizedBox(height: VeciEspacio.l),
          switch (catalogos) {
            AsyncData(:final value) => KeyedSubtree(key: ValueKey(_paso), child: _pregunta(value)),
            AsyncError() => const VeciAviso(
              tono: TonoAviso.error,
              mensaje: 'Para pedir el registro necesitas internet. Conéctate y vuelve a entrar.',
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          if (_problema != null) ...[
            const SizedBox(height: VeciEspacio.m),
            VeciAviso(tono: TonoAviso.aviso, mensaje: _problema!),
          ],
          const SizedBox(height: VeciEspacio.l),
          VeciBoton(
            texto: _ultimo ? (_ocupado ? 'Enviando…' : 'Enviar solicitud a VECI') : 'Seguir',
            grande: true,
            alTocar: _ocupado || catalogos is! AsyncData ? null : (_ultimo ? _solicitar : _seguir),
          ),
          if (_indice > 0)
            TextButton(
              onPressed: _ocupado
                  ? null
                  : () => setState(() {
                      _indice--;
                      _problema = null;
                    }),
              child: const Text('Atrás'),
            ),
        ],
      ),
    );
  }

  Widget _pregunta(CatalogosAlta catalogos) => switch (_paso) {
    PasoAlta.nombre => PreguntaTexto(
      titulo: '¿Cómo se llama tu negocio?',
      etiqueta: 'Nombre como lo conoce la gente',
      valor: _borrador.nombre,
      alCambiar: (v) => _cambiar(_borrador.copiar(nombre: v)),
    ),
    PasoAlta.tipo => PreguntaTipo(borrador: _borrador, tipos: catalogos.tipos, alCambiar: _cambiar),
    PasoAlta.documento => PreguntaDocumento(borrador: _borrador, alCambiar: _cambiar),
    PasoAlta.contacto => PreguntaTexto(
      titulo: '¿A qué número te escribe la gente?',
      etiqueta: 'Celular del negocio',
      valor: _borrador.celular,
      celular: true,
      alCambiar: (v) => _cambiar(_borrador.copiar(celular: v)),
    ),
    PasoAlta.lugar => PreguntaLugar(
      borrador: _borrador,
      municipios: catalogos.municipios,
      alCambiar: _cambiar,
    ),
    PasoAlta.letrero => Letrero(
      borrador: _borrador,
      tipo: catalogos.tipos.where((t) => t.codigo == _borrador.tipoNegocio).firstOrNull,
      municipio: catalogos.municipios
          .where((m) => m.id == _borrador.municipioId)
          .firstOrNull
          ?.nombre,
    ),
  };
}

/// La solicitud quedó radicada: VECI la revisa y la persona ve en Ajustes en qué va.
class _SolicitudEnviada extends StatelessWidget {
  const _SolicitudEnviada({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Solicitud enviada')),
    body: ListView(
      padding: const EdgeInsets.all(VeciEspacio.l),
      children: [
        const Icon(Icons.mark_email_read, size: 64, color: VeciColores.selva),
        const SizedBox(height: VeciEspacio.m),
        Text(
          'Recibimos tu solicitud para $nombre',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: VeciTexto.grande, fontWeight: VeciPeso.fuerte),
        ),
        const SizedBox(height: VeciEspacio.m),
        const Text(
          'El equipo de VECI la revisa y, cuando la apruebe, entras a tu negocio desde '
          'Ajustes. Mientras tanto sigues usando VECI como cliente.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: VeciEspacio.l),
        VeciBoton(texto: 'Listo', grande: true, alTocar: () => Navigator.of(context).maybePop()),
      ],
    ),
  );
}
