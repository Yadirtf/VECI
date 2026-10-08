import '../entities/alta.dart';
import '../entities/solicitud.dart';

/// Pedir el registro de un negocio desde el celular (HU-03-01). VECI lo revisa y, al
/// aprobarlo, la persona queda como dueña.
abstract interface class ComerciosRepository {
  Future<CatalogosAlta> catalogos();

  Future<void> solicitar(BorradorAlta borrador);

  /// Las solicitudes de la persona, la más reciente primero.
  Future<List<SolicitudDeNegocio>> misSolicitudes();
}
