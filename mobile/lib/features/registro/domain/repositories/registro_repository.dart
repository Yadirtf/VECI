import '../entities/registro.dart';

/// Crear la cuenta del cliente desde la app (HU-04-01). Necesita internet.
abstract interface class RegistroRepository {
  Future<List<TipoDocumento>> tiposDeDocumento();

  Future<PoliticaDeDatos> politica();

  /// Crea la cuenta con la política aceptada y deja la sesión abierta en el celular.
  Future<void> registrarme(BorradorRegistro borrador, String politicaVersionId);
}
