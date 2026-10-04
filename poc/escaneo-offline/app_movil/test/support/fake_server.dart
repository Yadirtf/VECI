import 'dart:math';

import 'package:veci_poc_escaneo/core/error/network_failure.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/entities/delivery_result.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/entities/offline_data.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/entities/outbox_item.dart';
import 'package:veci_poc_escaneo/features/sincronizacion/domain/repositories/sync_remote.dart';

/// Servidor falso con la misma regla que el real: la PK es el id del evento.
/// Con [cutRate] guarda el lote y "pierde" la respuesta, como un corte de señal.
class FakeIdempotentServer implements SyncRemote {
  FakeIdempotentServer({this.cutRate = 0, int seed = 7}) : _random = Random(seed);

  final double cutRate;
  final Random _random;
  final Map<String, OutboxItem> stored = {};
  final List<DateTime> appliedOrder = [];
  int deliveries = 0;
  int replays = 0;
  int cuts = 0;

  @override
  Future<List<DeliveryResult>> sendBatch(OutboxBatch batch, SendOptions options) async {
    final results = batch.items.map(_receive).toList();
    if (_random.nextDouble() < cutRate) {
      cuts++;
      throw const NetworkFailure('corte simulado');
    }
    return results;
  }

  DeliveryResult _receive(OutboxItem item) {
    deliveries++;
    final replayed = stored.containsKey(item.id);
    if (replayed) {
      replays++;
    } else {
      stored[item.id] = item;
      appliedOrder.add(item.occurredAt);
    }
    return DeliveryResult(eventId: item.id, statusCode: 'APPLIED', replayed: replayed);
  }

  @override
  Future<OfflineData> fetchOfflineData() => throw UnimplementedError();

  @override
  Future<Map<String, num>> fetchServerStats() async => {'eventosUnicos': stored.length};

  @override
  Future<void> resetServer() async => stored.clear();
}
