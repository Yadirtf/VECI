import 'package:flutter/material.dart';

import 'core/theme/veci_theme.dart';
import 'features/escaneo/presentation/pages/scan_page.dart';
import 'features/sincronizacion/presentation/pages/sync_page.dart';

class VeciPocApp extends StatelessWidget {
  const VeciPocApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VECI · Prueba de escaneo',
    theme: VeciTheme.light(),
    debugShowCheckedModeBanner: false,
    home: const _Home(),
  );
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Cobrar con QR' : 'Sincronizar')),
      // Sin IndexedStack: al salir de "Cobrar" la cámara se apaga.
      body: _tab == 0 ? const ScanPage() : const SyncPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Cobrar'),
          NavigationDestination(icon: Icon(Icons.sync), label: 'Sincronizar'),
        ],
      ),
    );
  }
}
