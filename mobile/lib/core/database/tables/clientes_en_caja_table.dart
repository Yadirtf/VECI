import 'package:drift/drift.dart';

/// Copia local de los clientes de cada negocio para buscarlos sin internet (HU-04-05).
/// Guarda solo lo que manda GET /clientes/copia-local: el documento y el celular
/// enmascarados y sus últimos 4 números. Nunca documentos completos.
@DataClassName('ClienteEnCajaLocal')
class ClientesEnCaja extends Table {
  TextColumn get comercioId => text()();
  TextColumn get clienteId => text()();
  TextColumn get nombre => text()();

  /// Minúsculas y sin tildes, como lo manda la API.
  TextColumn get nombreBusqueda => text()();

  /// "****5678".
  TextColumn get documento => text()();
  TextColumn get documentoFinal => text()();

  /// "••• 8888".
  TextColumn get celular => text().nullable()();
  TextColumn get celularFinal => text().nullable()();

  /// ACTIVA, PENDIENTE o SIN_CUENTA.
  TextColumn get cuenta => text()();

  /// ACTIVE, BLOCKED o ENDED.
  TextColumn get estado => text()();

  @override
  Set<Column<Object>> get primaryKey => {comercioId, clienteId};
}

/// Versión de la copia de clientes de cada negocio: con su ETag el servidor responde
/// 304 si nada cambió. [alDiaEn] es la última vez que el servidor la confirmó.
@DataClassName('CopiaDeClientesLocal')
class CopiasDeClientes extends Table {
  TextColumn get comercioId => text()();
  TextColumn get version => text()();
  TextColumn get etag => text().nullable()();
  DateTimeColumn get alDiaEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {comercioId};
}
