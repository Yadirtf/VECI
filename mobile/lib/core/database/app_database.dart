import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/horarios_locales_table.dart';

part 'app_database.g.dart';

/// Base local del celular (Drift sobre SQLite): la app funciona sin internet (ADR-0004).
@DriftDatabase(tables: [HorariosLocales])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base en el almacenamiento de la app, abierta en un isolate aparte.
  factory AppDatabase.enElCelular() => AppDatabase(driftDatabase(name: 'veci'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (detalles) async {
      // WAL: escrituras rápidas sin bloquear lecturas (ADR-0011).
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
    },
  );
}
