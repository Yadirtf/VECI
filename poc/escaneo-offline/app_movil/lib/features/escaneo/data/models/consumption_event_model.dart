import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/outbox_dao.dart';
import '../../domain/entities/consumption_event.dart';

/// Código de sync.inbound_event_kinds y de consumptions.capture_methods.
const consumptionKindCode = 'CONSUMPTION';
const qrScanCaptureCode = 'QR_SCAN';

/// Convierte un consumo en la fila de la bandeja de salida. Los nombres del
/// payload son los de las columnas del modelo de datos (HU-00-03).
extension ConsumptionEventModel on ConsumptionEvent {
  OutboxEventsCompanion toOutboxRow() => OutboxEventsCompanion.insert(
    id: id,
    kindCode: consumptionKindCode,
    occurredAt: occurredAt.toUtc(),
    payloadJson: jsonEncode(toPayload()),
    statusCode: outboxPendingCode,
    batchId: const Value(null),
  );

  Map<String, Object?> toPayload() => {
    'tenant_id': tenantId,
    'affiliation_id': affiliationId,
    'affiliation_qr_code_id': affiliationQrCodeId,
    'qr_version': qrVersion,
    'capture_method': qrScanCaptureCode,
    'units_requested': unitsRequested,
    'business_date': _localDate(occurredAt),
  };
}

/// Fecha local del comercio en que ocurrió (consumptions.business_date).
String _localDate(DateTime at) {
  final local = at.toLocal();
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  return '${local.year}-$mm-$dd';
}
