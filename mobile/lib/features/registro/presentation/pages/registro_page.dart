import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/registro_providers.dart';
import '../../../../core/error/fallo.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../../../core/ui/veci_piedras.dart';
import '../../domain/entities/registro.dart';
import '../../domain/reglas/reglas_registro.dart';
import '../providers/registro_providers.dart';
import '../widgets/bienvenida.dart';
import '../widgets/politica_en_corto.dart';
import '../widgets/preguntas_registro.dart';

/// Crear la cuenta del cliente como una conversación (HU-04-01): una pregunta por
/// pantalla y, al final, la bienvenida. Al crearla entra de una vez.
class RegistroPage extends ConsumerStatefulWidget {
  const RegistroPage({super.key});

  @override
  ConsumerState<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends ConsumerState<RegistroPage> {
  var _indice = 0;
  var _borrador = const BorradorRegistro();
  String? _problema;
  var _ocupado = false;
  var _yaEstaEnVeci = false;
  var _registrado = false;

  PasoRegistro get _paso => PasoRegistro.values[_indice];

  void _cambiar(BorradorRegistro nuevo) => setState(() => _borrador = nuevo);

  void _seguir(List<TipoDocumento> tipos) {
    final falta = problemaEnPaso(_paso, _borrador, tipos);
    setState(() {
      _problema = falta;
      if (falta == null) _indice++;
    });
  }

  void _atras() => setState(() {
    _indice--;
    _problema = null;
    _yaEstaEnVeci = false;
  });

  Future<void> _crear(List<TipoDocumento> tipos, PoliticaDeDatos politica) async {
    final falta = problemaEnPaso(_paso, _borrador, tipos);
    setState(() => _problema = falta);
    if (falta != null) return;
    setState(() => _ocupado = true);
    try {
      await ref.read(registroRepositoryProvider).registrarme(_borrador, politica.id);
      if (mounted) setState(() => _registrado = true);
    } on Object catch (error) {
      if (mounted) _explicar(error);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _explicar(Object error) {
    final motivo = error is PeticionRechazada ? error.motivo : null;
    if (motivo == motivoPoliticaDesactualizada) ref.invalidate(politicaDeDatosProvider);
    setState(() {
      _problema = switch (error) {
        SinConexion() => 'Para crear tu cuenta necesitas internet. Lo escrito no se pierde.',
        PeticionRechazada(:final mensaje) => mensaje,
        _ => 'No pudimos crear tu cuenta. Intenta otra vez en un momento.',
      };
      _yaEstaEnVeci = motivosParaEntrar.contains(motivo);
      if (motivo == motivoPoliticaDesactualizada) _indice = PasoRegistro.politica.index;
    });
  }

  void _irAEntrar() => context.go(Rutas.entrarCon(celularLimpio(_borrador.celular)));

  @override
  Widget build(BuildContext context) {
    if (_registrado) {
      return Bienvenida(nombre: _borrador.nombres, alVerMiQr: () => context.go(Rutas.miQr));
    }
    final tipos = ref.watch(tiposDeDocumentoProvider);
    final politica = ref.watch(politicaDeDatosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tu cuenta en VECI')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeciEspacio.l),
              children: [
                PiedrasDelCamino(total: PasoRegistro.values.length, actual: _indice),
                const SizedBox(height: VeciEspacio.l),
                _contenido(tipos, politica),
                if (_problema != null) ...[
                  const SizedBox(height: VeciEspacio.m),
                  VeciAviso(tono: TonoAviso.aviso, mensaje: _problema!),
                ],
              ],
            ),
          ),
          VeciMostrador(
            children: [
              _botonPrincipal(tipos.value, politica.value),
              if (_indice > 0 && !_ocupado)
                TextButton(onPressed: _atras, child: const Text('Atrás')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contenido(AsyncValue<List<TipoDocumento>> tipos, AsyncValue<PoliticaDeDatos> politica) {
    final (listaTipos, laPolitica) = (tipos.value, politica.value);
    if (listaTipos != null && laPolitica != null) {
      return KeyedSubtree(key: ValueKey(_paso), child: _pregunta(listaTipos, laPolitica));
    }
    if (tipos.hasError || politica.hasError) {
      return Column(
        children: [
          const VeciAviso(
            tono: TonoAviso.error,
            mensaje: 'Para crear tu cuenta necesitas internet. Conéctate y vuelve a intentar.',
          ),
          TextButton(
            onPressed: () => ref
              ..invalidate(tiposDeDocumentoProvider)
              ..invalidate(politicaDeDatosProvider),
            child: const Text('Intentar otra vez'),
          ),
        ],
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _pregunta(List<TipoDocumento> tipos, PoliticaDeDatos politica) => switch (_paso) {
    PasoRegistro.celular => PreguntaCelular(borrador: _borrador, alCambiar: _cambiar),
    PasoRegistro.nombre => PreguntaNombre(borrador: _borrador, alCambiar: _cambiar),
    PasoRegistro.documento => PreguntaDocumento(
      borrador: _borrador,
      tipos: tipos,
      alCambiar: _cambiar,
    ),
    PasoRegistro.politica => PoliticaEnCorto(
      politica: politica,
      alLeerCompleta: () => unawaited(context.push(Rutas.politica)),
    ),
    PasoRegistro.pin => PreguntaPin(borrador: _borrador, alCambiar: _cambiar),
  };

  Widget _botonPrincipal(List<TipoDocumento>? tipos, PoliticaDeDatos? politica) {
    if (_yaEstaEnVeci) {
      return VeciBoton(texto: 'Entrar con mi celular', grande: true, alTocar: _irAEntrar);
    }
    if (tipos == null || politica == null || _ocupado) {
      return VeciBoton(
        texto: _ocupado ? 'Creando tu cuenta…' : 'Seguir',
        grande: true,
        alTocar: null,
      );
    }
    return switch (_paso) {
      PasoRegistro.politica => VeciBoton(
        texto: 'Acepto y creo mi cuenta',
        grande: true,
        alTocar: () => _seguir(tipos),
      ),
      PasoRegistro.pin => VeciBoton(
        texto: 'Crear mi cuenta',
        grande: true,
        alTocar: () => unawaited(_crear(tipos, politica)),
      ),
      _ => VeciBoton(texto: 'Seguir', grande: true, alTocar: () => _seguir(tipos)),
    };
  }
}
