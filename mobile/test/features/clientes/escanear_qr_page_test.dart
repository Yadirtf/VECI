import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/clientes/domain/entities/lectura_qr.dart';
import 'package:veci/features/clientes/presentation/pages/escanear_qr_page.dart';
import 'package:veci/features/clientes/presentation/widgets/mensajes_clientes.dart';

import 'app_de_prueba.dart';
import 'clientes_dobles.dart';

/// En lugar de la cámara, un botón que "lee" un QR.
Widget _visorFalso(bool activo, ValueChanged<String> alLeer) => Center(
  child: TextButton(
    onPressed: activo ? () => alLeer('VP1.abc.firma') : null,
    child: const Text('Leer QR de prueba'),
  ),
);

final _escanerDePrueba = GoRoute(
  path: '/prueba-escaner',
  builder: (_, _) => const EscanearQrPage(visor: _visorFalso),
);

Future<void> _leer(WidgetTester tester) async {
  await tester.tap(find.text('Leer QR de prueba'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('persona por afiliar: confirma y abre su ficha', (tester) async {
    final repositorio = RepositorioClientesFalso();
    await abrirCaja(tester, repositorio, ruta: '/prueba-escaner', otras: [_escanerDePrueba]);

    await _leer(tester);
    expect(find.text('¿Es Luz Marina C.?'), findsOneWidget);
    expect(find.text('Cédula ****5678'), findsOneWidget);

    await tester.tap(find.text('Sí, afiliar'));
    await tester.pumpAndSettle();
    expect(repositorio.afiliados, ['VP1.abc.firma']);
    expect(find.text('¡Listo, veci! Ya es cliente de tu negocio.'), findsOneWidget);
  });

  testWidgets('si ya es cliente abre su ficha y lo dice', (tester) async {
    final repositorio = RepositorioClientesFalso()..lectura = YaEsCliente(fichaDePrueba());
    await abrirCaja(tester, repositorio, ruta: '/prueba-escaner', otras: [_escanerDePrueba]);

    await _leer(tester);

    expect(find.text('Ya es cliente de tu negocio.'), findsOneWidget);
    expect(find.text('Ficha del cliente'), findsOneWidget);
  });

  testWidgets('un QR cambiado no muestra nombre y deja escanear otro', (tester) async {
    final repositorio = RepositorioClientesFalso()..lectura = const QrCambiado();
    await abrirCaja(tester, repositorio, ruta: '/prueba-escaner', otras: [_escanerDePrueba]);

    await _leer(tester);
    expect(find.textContaining('fue cambiado'), findsOneWidget);
    expect(find.textContaining('Luz'), findsNothing);

    await tester.tap(find.text('Escanear otro'));
    await tester.pumpAndSettle();
    expect(find.text('Apunta la cámara al QR del cliente.'), findsOneWidget);
  });

  testWidgets('sin internet hace una pausa honesta', (tester) async {
    final repositorio = RepositorioClientesFalso()..fallo = const SinConexion();
    await abrirCaja(tester, repositorio, ruta: '/prueba-escaner', otras: [_escanerDePrueba]);

    await _leer(tester);

    expect(find.text(pausaParaLeerQr), findsOneWidget);
  });
}
