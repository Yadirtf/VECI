import 'package:drift/drift.dart';

/// QR revocados del comercio (customers.affiliation_qr_codes con revoked_at).
class RevokedQrCodes extends Table {
  TextColumn get qrCodeId => text()();
  TextColumn get tenantId => text()();

  @override
  Set<Column> get primaryKey => {qrCodeId};
}
