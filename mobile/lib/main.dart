import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/network/api_config.dart';
import 'core/observabilidad/sentry_veci.dart';

Future<void> main() async {
  await SentryFlutter.init(
    SentryVeci.configurar,
    appRunner: () async {
      await SentryVeci.etiquetarComercio(ApiConfig.desdeEntorno().comercioId);
      runApp(const ProviderScope(child: VeciApp()));
    },
  );
}
