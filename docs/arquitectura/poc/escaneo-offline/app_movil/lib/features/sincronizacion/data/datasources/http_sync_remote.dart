import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/error/network_failure.dart';
import '../../../../core/network/api_config.dart';
import '../../domain/entities/delivery_result.dart';
import '../../domain/entities/offline_data.dart';
import '../../domain/entities/outbox_item.dart';
import '../../domain/repositories/sync_remote.dart';
import '../models/sync_json.dart';

class HttpSyncRemote implements SyncRemote {
  HttpSyncRemote(this._config, [http.Client? client]) : _client = client ?? http.Client();

  final ApiConfig _config;
  final http.Client _client;

  @override
  Future<List<DeliveryResult>> sendBatch(OutboxBatch batch, SendOptions options) async {
    final query = options.simulatedCutRate > 0
        ? {'simular_corte': options.simulatedCutRate.toString()}
        : null;
    final body = jsonEncode(batchToJson(batch, options));
    final response = await _guard(
      () => _client.post(
        _config.uri('/poc/sync/batches', query),
        headers: const {'Content-Type': 'application/json'},
        body: body,
      ),
    );
    return resultsFromJson(response.body);
  }

  @override
  Future<OfflineData> fetchOfflineData() async {
    final response = await _guard(() => _client.get(_config.uri('/poc/datos-offline')));
    return offlineDataFromJson(response.body);
  }

  @override
  Future<Map<String, num>> fetchServerStats() async {
    final response = await _guard(() => _client.get(_config.uri('/poc/sync/stats')));
    return (jsonDecode(response.body) as Map<String, dynamic>).cast<String, num>();
  }

  @override
  Future<void> resetServer() => _guard(() => _client.post(_config.uri('/poc/sync/reset')));

  /// Convierte cualquier falta de respuesta en NetworkFailure, que se reintenta.
  Future<http.Response> _guard(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(_config.timeout);
      if (response.statusCode >= 500) {
        throw NetworkFailure('Servidor respondió ${response.statusCode}');
      }
      if (response.statusCode >= 400) throw StateError('Petición inválida: ${response.body}');
      return response;
    } on TimeoutException {
      throw const NetworkFailure('Tiempo de espera agotado');
    } on SocketException catch (e) {
      throw NetworkFailure(e.message);
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
