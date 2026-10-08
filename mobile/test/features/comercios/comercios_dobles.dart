import 'package:veci/features/comercios/domain/entities/alta.dart';
import 'package:veci/features/comercios/domain/entities/solicitud.dart';
import 'package:veci/features/comercios/domain/repositories/comercios_repository.dart';

/// Servidor de mentiras para las solicitudes de negocio.
class ComerciosFalsos implements ComerciosRepository {
  ComerciosFalsos({this.solicitudes = const []});

  BorradorAlta? solicitado;
  List<SolicitudDeNegocio> solicitudes;

  @override
  Future<CatalogosAlta> catalogos() async => const CatalogosAlta(
    tipos: [
      TipoDeNegocio(codigo: 'BAKERY', nombre: 'Panadería', servicios: ['Pan de la mañana']),
    ],
    municipios: [Municipio(id: 86001, nombre: 'Mocoa')],
  );

  @override
  Future<void> solicitar(BorradorAlta borrador) async => solicitado = borrador;

  @override
  Future<List<SolicitudDeNegocio>> misSolicitudes() async => solicitudes;
}
