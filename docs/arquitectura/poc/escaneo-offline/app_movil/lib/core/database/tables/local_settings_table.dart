import 'package:drift/drift.dart';

/// Datos propios del celular: id del dispositivo, comercio, última bajada.
class LocalSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
