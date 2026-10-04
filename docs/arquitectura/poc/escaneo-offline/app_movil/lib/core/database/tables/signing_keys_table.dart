import 'package:drift/drift.dart';

/// Copia local de tenancy.tenant_signing_keys: solo la clave pública.
class SigningKeys extends Table {
  TextColumn get tenantId => text()();
  TextColumn get keyId => text()();
  TextColumn get algorithm => text()();
  BlobColumn get publicKey => blob()();
  DateTimeColumn get retiredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tenantId, keyId};
}
