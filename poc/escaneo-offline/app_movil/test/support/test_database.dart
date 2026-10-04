import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:veci_poc_escaneo/core/database/app_database.dart';

/// Base SQLite en memoria con el mismo esquema que el celular.
AppDatabase memoryDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
