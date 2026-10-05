import '../entities/alta.dart';

/// Registrar un negocio desde el celular (HU-03-01).
abstract interface class ComerciosRepository {
  Future<List<TipoDeNegocio>> tipos();

  /// Devuelve el id del negocio nuevo para dejarlo activo.
  Future<String> registrar(BorradorAlta borrador);
}
