import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/comercios_providers.dart';
import '../../../../core/di/sesion_providers.dart';
import '../../../../core/error/fallo.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../domain/entities/alta.dart';
import '../../domain/reglas/reglas_alta.dart';
import '../providers/alta_providers.dart';
import '../widgets/letrero.dart';
import '../widgets/piedras_del_camino.dart';
import '../widgets/preguntas_alta.dart';

/// Registrar el negocio desde el celular como una conversación (HU-03-01): una
/// pregunta por pantalla y, al final, el letrero. Al terminar queda como negocio activo.
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

  Future<void> _registrar() async {
    setState(() {
      _ocupado = true;
      _problema = null;
    });
    try {
      final comercioId = await ref.read(comerciosRepositoryProvider).registrar(_borrador);
      await ref.read(gestorSesionProvider).estrenarNegocio(comercioId);
    } on Object catch (error) {
      if (mounted) setState(() => _problema = _mensaje(error));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  static String _mensaje(Object error) => switch (error) {
    SinConexion() => 'Para registrar el negocio necesitas internet. Lo escrito no se pierde.',
    PeticionRechazada(:final mensaje) => mensaje,
    _ => 'No pudimos registrar tu negocio. Intenta otra vez en un momento.',
  };

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(tiposDeNegocioProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar mi negocio')),
      body: ListView(
        padding: const EdgeInsets.all(VeciEspacio.l),
        children: [
          PiedrasDelCamino(total: PasoAlta.values.length, actual: _indice),
          const SizedBox(height: VeciEspacio.l),
          switch (tipos) {
            AsyncData(:final value) => KeyedSubtree(key: ValueKey(_paso), child: _pregunta(value)),
            AsyncError() => const VeciAviso(
              tono: TonoAviso.error,
              mensaje: 'Para registrar el negocio necesitas internet. Conéctate y vuelve a entrar.',
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          if (_problema != null) ...[
            const SizedBox(height: VeciEspacio.m),
            VeciAviso(tono: TonoAviso.aviso, mensaje: _problema!),
          ],
          const SizedBox(height: VeciEspacio.l),
          VeciBoton(
            texto: _ultimo
                ? (_ocupado ? 'Colgando el letrero…' : 'Abrir mi negocio en VECI')
                : 'Seguir',
            grande: true,
            alTocar: _ocupado || tipos is! AsyncData ? null : (_ultimo ? _registrar : _seguir),
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

  Widget _pregunta(List<TipoDeNegocio> tipos) => switch (_paso) {
    PasoAlta.nombre => PreguntaTexto(
      titulo: '¿Cómo se llama tu negocio?',
      etiqueta: 'Nombre como lo conoce la gente',
      valor: _borrador.nombre,
      alCambiar: (v) => _cambiar(_borrador.copiar(nombre: v)),
    ),
    PasoAlta.tipo => PreguntaTipo(borrador: _borrador, tipos: tipos, alCambiar: _cambiar),
    PasoAlta.documento => PreguntaDocumento(borrador: _borrador, alCambiar: _cambiar),
    PasoAlta.contacto => PreguntaTexto(
      titulo: '¿A qué número te escribe la gente?',
      etiqueta: 'Celular del negocio',
      valor: _borrador.celular,
      celular: true,
      alCambiar: (v) => _cambiar(_borrador.copiar(celular: v)),
    ),
    PasoAlta.letrero => Letrero(
      borrador: _borrador,
      tipo: tipos.where((t) => t.codigo == _borrador.tipoNegocio).firstOrNull,
    ),
  };
}
