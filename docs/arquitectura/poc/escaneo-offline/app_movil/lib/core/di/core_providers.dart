import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../domain/clock.dart';
import '../domain/id_generator.dart';
import '../ids/system_clock.dart';
import '../ids/uuid_v7_generator.dart';
import '../network/api_config.dart';
import '../sync/outbox_dao.dart';

/// Piezas compartidas. Las pruebas reemplazan la base por una en memoria.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.onDevice();
  ref.onDispose(db.close);
  return db;
});

final outboxDaoProvider = Provider<OutboxDao>((ref) => OutboxDao(ref.watch(appDatabaseProvider)));

final idGeneratorProvider = Provider<IdGenerator>((ref) => UuidV7Generator());

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig.fromEnvironment());
