import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables/local_settings_table.dart';

part 'local_settings_dao.g.dart';

@DriftAccessor(tables: [LocalSettings])
class LocalSettingsDao extends DatabaseAccessor<AppDatabase> with _$LocalSettingsDaoMixin {
  LocalSettingsDao(super.attachedDatabase);

  Future<String?> read(String key) async {
    final row = await (select(localSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) =>
      into(localSettings)
          .insertOnConflictUpdate(LocalSettingsCompanion.insert(key: key, value: value));
}
