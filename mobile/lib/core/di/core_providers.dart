import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../database/app_database.dart';
import '../network/api_config.dart';
import '../network/cliente_api.dart';
import '../observabilidad/sentry_veci.dart';
import '../observabilidad/vigilante_sincronizacion.dart';
import 'sesion_providers.dart';

/// Piezas compartidas. Las pruebas reemplazan la base o la red por dobles.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.enElCelular();
  ref.onDispose(db.close);
  return db;
});

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig.desdeEntorno());

/// Cliente del API con la sesión: pone el token y lo renueva solo.
final clienteApiProvider = Provider<ApiClient>(
  (ref) => crearClienteApi(ref.watch(apiConfigProvider), sesion: ref.watch(fuenteDeTokenProvider)),
);

/// Uno para toda la app: cuenta los fallos seguidos contra el servidor y alerta en Sentry.
final vigilanteSincronizacionProvider = Provider<VigilanteSincronizacion>(
  (ref) => VigilanteSincronizacion(alertar: SentryVeci.alertarSincronizacion),
);

/// Hora del celular; las pruebas la fijan para que "¿ya es hora?" sea predecible.
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);
