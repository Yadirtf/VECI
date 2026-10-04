import 'package:sentry_flutter/sentry_flutter.dart';

/// Configuración de Sentry para la app (HU-01-07): versión y comercio, sin datos personales.
abstract final class SentryVeci {
  static const dsn = String.fromEnvironment('SENTRY_DSN');
  static const entorno = String.fromEnvironment('VECI_ENTORNO', defaultValue: 'desarrollo');

  static void configurar(SentryFlutterOptions opciones) {
    opciones
      ..dsn = dsn
      ..environment = entorno
      ..sendDefaultPii = false
      ..attachScreenshot = false
      ..tracesSampleRate = 0
      ..beforeSend = _sinDatosPersonales;
  }

  /// Etiqueta los errores con el comercio activo (un id, no un dato personal).
  static Future<void> etiquetarComercio(String? comercioId) async {
    await Sentry.configureScope(
      (scope) =>
          comercioId == null ? scope.removeTag('comercio') : scope.setTag('comercio', comercioId),
    );
  }

  /// Evento con etiqueta fija para la regla de alerta "sincronización falla" en Sentry.
  static void alertarSincronizacion(int fallosSeguidos, Object ultimoError) {
    Sentry.captureMessage(
      'La sincronización falló $fallosSeguidos veces seguidas',
      level: SentryLevel.error,
      withScope: (scope) {
        scope.setTag('veci.alerta', 'sincronizacion');
        scope.setTag('veci.error', ultimoError.runtimeType.toString());
        scope.fingerprint = ['veci-sincronizacion-falla'];
      },
    );
  }

  static SentryEvent? _sinDatosPersonales(SentryEvent evento, Hint _) {
    evento.user = null;
    evento.request = null;
    return evento;
  }
}
