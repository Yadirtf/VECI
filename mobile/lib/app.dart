import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/veci_tema.dart';

class VeciApp extends StatefulWidget {
  const VeciApp({super.key});

  @override
  State<VeciApp> createState() => _VeciAppState();
}

class _VeciAppState extends State<VeciApp> {
  final _router = crearRouter();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'VECI',
    theme: VeciTema.claro(),
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
  );
}
