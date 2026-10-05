import '../entities/mi_qr.dart';

/// Mi QR y Tus negocios: el servidor manda y el celular guarda una copia, así los QR
/// se muestran sin internet.
abstract interface class MiQrRepository {
  /// Lo guardado en el celular, sin ir a la red; null si nunca se bajó.
  Future<MiQr?> qrGuardado();

  /// Pide el QR al servidor y guarda la copia.
  Future<MiQr> traerQr();

  /// QR nuevo: el anterior deja de servir. Necesita internet.
  Future<MiQr> regenerar();

  Future<List<NegocioDondeSoyCliente>?> negociosGuardados();

  Future<List<NegocioDondeSoyCliente>> traerNegocios();

  /// Al salir: el QR de una persona no se queda en el celular de otra.
  Future<void> olvidar();
}
