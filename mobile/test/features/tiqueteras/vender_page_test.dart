import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/tiqueteras/domain/entities/catalogo.dart';
import 'package:veci/features/tiqueteras/domain/entities/venta.dart';
import 'package:veci/features/tiqueteras/presentation/widgets/textos_tiqueteras.dart';

import 'app_de_prueba.dart';
import 'tiqueteras_dobles.dart';

final _ruta = Rutas.venderA('c1', nombre: 'Luz Marina');

void main() {
  testWidgets('en línea: cobra lo de la pizarra y sella la venta', (tester) async {
    final ventas = VentasFalsas();
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    expect(find.text('Vender a Luz Marina'), findsOneWidget);
    await tocar(tester, '20 almuerzos · \$ 220.000');
    await tocar(tester, 'Efectivo');
    await tocar(tester, 'Cobrar \$ 220.000');

    final venta = ventas.vendidas.single;
    expect(venta.ventaId, 'venta-1');
    expect(venta.clienteId, 'c1');
    expect(venta.pago.medio, 'CASH');
    expect(venta.ocurridaEn, DateTime(2026, 10, 8, 12));
    expect(find.text('VENDIDA'), findsOneWidget);
    expect(find.text('+20'), findsOneWidget);
  });

  testWidgets('sin señal: la venta queda guardada y no se cobra otra vez', (tester) async {
    final ventas = VentasFalsas()
      ..sinSenal = true
      ..catalogo = catalogoDePrueba.conSenal(sinSenal: true);
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    expect(find.text('Sin señal: vendes con lo guardado.'), findsOneWidget);
    await tocar(tester, '20 almuerzos · \$ 220.000');
    await tocar(tester, 'Efectivo');
    await tocar(tester, 'Cobrar \$ 220.000');

    expect(find.text(ventaGuardada), findsOneWidget);
    expect(ventas.vendidas, hasLength(1));
  });

  testWidgets('transferencia sin canal: pide por dónde llegó', (tester) async {
    final ventas = VentasFalsas();
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    await tocar(tester, '20 almuerzos · \$ 220.000');
    await tocar(tester, 'Transferencia');
    expect(find.text('¿Por dónde llegó?'), findsOneWidget);
    await tocar(tester, 'Cobrar \$ 220.000');
    expect(ventas.vendidas, isEmpty);

    await tocar(tester, 'Nequi');
    await tocar(tester, 'Cobrar \$ 220.000');
    expect(ventas.vendidas.single.pago.canal, 'NEQUI');
  });

  testWidgets('sin elegir tiquetera no cobra', (tester) async {
    final ventas = VentasFalsas();
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    await tocar(tester, 'Cobrar');
    expect(find.text('Elige cuál tiquetera lleva.'), findsOneWidget);
    expect(ventas.vendidas, isEmpty);
  });

  testWidgets('si la pizarra cambió, dice lo que respondió el servidor', (tester) async {
    final ventas = VentasFalsas()
      ..falloVenta = const PeticionRechazada(409, 'El precio cambió: ahora es \$ 240.000.');
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    await tocar(tester, '20 almuerzos · \$ 220.000');
    await tocar(tester, 'Efectivo');
    await tocar(tester, 'Cobrar \$ 220.000');
    expect(find.text('El precio cambió: ahora es \$ 240.000.'), findsOneWidget);
  });

  testWidgets('muestra la cola y deja quitar una venta rechazada', (tester) async {
    final ventas = VentasFalsas()
      ..cola = [
        VentaPorEnviar(
          ventaId: 'v1',
          nombreCliente: 'Ana',
          nombreTipo: '20 almuerzos',
          precio: 220000,
          ocurridaEn: DateTime(2026, 10, 7),
        ),
        VentaPorEnviar(
          ventaId: 'v2',
          nombreCliente: 'Pedro',
          nombreTipo: '20 almuerzos',
          precio: 220000,
          ocurridaEn: DateTime(2026, 10, 7),
          rechazo: 'Ya no es cliente.',
        ),
      ];
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    expect(find.text('1 venta espera señal para enviarse.'), findsOneWidget);
    expect(find.text('No se registró: Ya no es cliente.'), findsOneWidget);
    await tocar(tester, 'Quitar');
    expect(ventas.cola.map((v) => v.ventaId), ['v1']);
    expect(find.text('No se registró: Ya no es cliente.'), findsNothing);
  });

  testWidgets('sin tiqueteras en la pizarra lo explica', (tester) async {
    final ventas = VentasFalsas()..catalogo = const CatalogoDeVenta(tipos: [], medios: [efectivo]);
    await abrirTiqueteras(tester, _ruta, ventas: ventas);

    expect(find.textContaining('No hay tiqueteras en venta'), findsOneWidget);
  });
}
