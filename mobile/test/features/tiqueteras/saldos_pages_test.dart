import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/tiqueteras/domain/entities/estado_de_cuenta.dart';
import 'package:veci/features/tiqueteras/presentation/widgets/textos_tiqueteras.dart';

import 'app_de_prueba.dart';
import 'tiqueteras_dobles.dart';

void main() {
  group('saldo del cliente en la caja', () {
    testWidgets('muestra el saldo, la pila y la historia', (tester) async {
      await abrirTiqueteras(tester, Rutas.saldoDe('c1', nombre: 'Luz Marina'));

      expect(find.text('Luz Marina'), findsOneWidget);
      expect(find.textContaining('14'), findsWidgets);
      expect(find.textContaining('20 almuerzos'), findsWidgets);
      expect(find.textContaining('Cortesía'), findsOneWidget);
    });

    testWidgets('sin señal explica que igual se le puede vender', (tester) async {
      final ventas = VentasFalsas()..falloCuenta = const SinConexion();
      await abrirTiqueteras(tester, Rutas.saldoDe('c1', nombre: 'Luz'), ventas: ventas);

      expect(find.text(sinSenalParaSaldo), findsOneWidget);
      await tocar(tester, 'Vender tiquetera');
      expect(find.text('Vender a Luz'), findsOneWidget);
    });
  });

  group('tus tiqueteras en la app del cliente', () {
    testWidgets('muestra lo que le queda en cada negocio', (tester) async {
      await abrirTiqueteras(tester, Rutas.tusTiqueteras);

      expect(find.text('Lo que te queda'), findsOneWidget);
      expect(find.text('Doña Rosa'), findsOneWidget);
      expect(find.textContaining('20 almuerzos'), findsWidgets);
    });

    testWidgets('sin señal muestra la copia guardada', (tester) async {
      final mias = MisTiqueterasFalsas()
        ..copia = [
          SaldoEnNegocio(comercioId: 'n1', comercio: 'Doña Rosa', cuenta: cuentaDePrueba()),
        ]
        ..fallo = const SinConexion();
      await abrirTiqueteras(tester, Rutas.tusTiqueteras, mias: mias);

      expect(find.text('Sin señal: te mostramos lo guardado.'), findsOneWidget);
      expect(find.text('Doña Rosa'), findsOneWidget);
    });

    testWidgets('sin copia ni señal pide conectarse', (tester) async {
      final mias = MisTiqueterasFalsas()..fallo = const SinConexion();
      await abrirTiqueteras(tester, Rutas.tusTiqueteras, mias: mias);

      expect(find.textContaining('la primera vez necesitas internet'), findsOneWidget);
    });

    testWidgets('sin tiqueteras lo dice', (tester) async {
      final mias = MisTiqueterasFalsas()..delServidor = [];
      await abrirTiqueteras(tester, Rutas.tusTiqueteras, mias: mias);

      expect(find.textContaining('Aún no tienes tiqueteras'), findsOneWidget);
    });
  });
}
