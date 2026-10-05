import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/clientes_providers.dart';
import '../../../../core/error/fallo.dart';
import '../../domain/entities/lectura_qr.dart';
import '../../domain/entities/registro_asistido.dart';
import '../../domain/reglas/reglas_registro.dart';
import '../widgets/mensajes_clientes.dart';
import 'copia_clientes_controller.dart';

/// Catálogo de tipos de documento (público; necesita señal la primera vez).
final tiposDeDocumentoProvider = FutureProvider.autoDispose<List<TipoDocumento>>(
  (ref) => ref.watch(clientesRepositoryProvider).tiposDeDocumento(),
);

/// La política vigente "en corto", para leerla en voz alta.
final politicaEnCortoProvider = FutureProvider.autoDispose<PoliticaEnCorto>(
  (ref) => ref.watch(clientesRepositoryProvider).politica(),
);

/// Pasos del registro asistido, todos en una sola pantalla (HU-04-04).
enum PasoRegistro { documento, encontrada, nueva, registrado }

class EstadoRegistro {
  const EstadoRegistro({
    this.paso = PasoRegistro.documento,
    this.ocupado = false,
    this.problema,
    this.persona,
    this.hecho,
    this.ofrecerCompartido = false,
  });

  final PasoRegistro paso;
  final bool ocupado;
  final String? problema;

  /// La persona que ya estaba en VECI con ese documento.
  final PersonaEncontrada? persona;
  final RegistroHecho? hecho;

  /// El celular es de otra cuenta: se ofrece registrarlo como compartido.
  final bool ofrecerCompartido;
}

final registroAsistidoProvider =
    NotifierProvider.autoDispose<RegistroAsistidoController, EstadoRegistro>(
      RegistroAsistidoController.new,
    );

class RegistroAsistidoController extends Notifier<EstadoRegistro> {
  DatosRegistroAsistido? _ultimo;

  @override
  EstadoRegistro build() => const EstadoRegistro();

  /// Primero el documento: si la persona ya está en VECI, solo se afilia.
  Future<void> revisar(TipoDocumento? tipo, String numero) async {
    final problema = problemaConDocumento(tipo, numero);
    if (problema != null) return _fallar(problema);
    state = const EstadoRegistro(ocupado: true);
    try {
      final persona = await ref
          .read(clientesRepositoryProvider)
          .revisarDocumento(tipo!.codigo, limpiarDocumento(numero));
      if (!ref.mounted) return;
      state = persona == null
          ? const EstadoRegistro(paso: PasoRegistro.nueva)
          : EstadoRegistro(paso: PasoRegistro.encontrada, persona: persona);
    } on Object catch (error) {
      if (ref.mounted) state = EstadoRegistro(problema: mensajeAlRegistrar(error));
    }
  }

  /// Un dato que falta, revisado en la pantalla antes de enviar.
  void avisar(String problema) => _fallar(problema);

  /// Volver a escribir el documento.
  void cambiarDocumento() => state = const EstadoRegistro();

  /// Registra (o afilia, si ya estaba) con la política leída y aceptada.
  Future<void> registrar(DatosRegistroAsistido datos) async {
    _ultimo = datos;
    state = EstadoRegistro(paso: state.paso, persona: state.persona, ocupado: true);
    try {
      final hecho = await ref.read(clientesRepositoryProvider).registrar(datos);
      if (!ref.mounted) return;
      ref.invalidate(copiaDeClientesProvider);
      state = EstadoRegistro(paso: PasoRegistro.registrado, hecho: hecho);
    } on Object catch (error) {
      if (!ref.mounted) return;
      final enUso = error is PeticionRechazada && error.motivo == 'CELULAR_EN_USO';
      _fallar(mensajeAlRegistrar(error), ofrecerCompartido: enUso);
    }
  }

  /// "Es el celular compartido de la familia": reenvía lo mismo marcándolo.
  Future<void> registrarConCelularCompartido() async {
    final ultimo = _ultimo;
    if (ultimo != null) await registrar(ultimo.conCelularCompartido());
  }

  void _fallar(String problema, {bool ofrecerCompartido = false}) => state = EstadoRegistro(
    paso: state.paso,
    persona: state.persona,
    problema: problema,
    ofrecerCompartido: ofrecerCompartido,
  );
}
