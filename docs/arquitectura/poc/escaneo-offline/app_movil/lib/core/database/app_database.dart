import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/local_settings_table.dart';
import 'tables/outbox_events_table.dart';
import 'tables/revoked_qr_codes_table.dart';
import 'tables/signing_keys_table.dart';

part 'app_database.g.dart';

/// Base local del celular del cajero (Drift sobre SQLite).
@DriftDatabase(tables: [OutboxEvents, SigningKeys, RevokedQrCodes, LocalSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base en el almacenamiento de la app, abierta en un isolate aparte.
  factory AppDatabase.onDevice() => AppDatabase(driftDatabase(name: 'veci_poc_escaneo'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // WAL: escrituras rápidas sin bloquear lecturas (RNF-REN-01).
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
    },
  );
}
