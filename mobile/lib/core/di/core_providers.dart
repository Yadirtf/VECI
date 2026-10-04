import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../database/app_database.dart';
import '../network/api_config.dart';
import '../network/cliente_api.dart';
import '../observabilidad/sentry_veci.dart';
import '../observabilidad/vigilante_sincronizacion.dart';

/// Piezas compartidas. Las pruebas reemplazan la base o la red por dobles.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.enElCelular();
  ref.onDispose(db.close);
  return db;
});

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig.desdeEntorno());

final clienteApiProvider = Provider<ApiClient>(
  (ref) => crearClienteApi(ref.watch(apiConfigProvider)),
);

/// Uno para toda la app: cuenta los fallos seguidos contra el servidor y alerta en Sentry.
final vigilanteSincronizacionProvider = Provider<VigilanteSincronizacion>(
  (ref) => VigilanteSincronizacion(alertar: SentryVeci.alertarSincronizacion),
);
