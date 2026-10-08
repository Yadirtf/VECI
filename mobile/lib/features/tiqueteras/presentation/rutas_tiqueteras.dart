import 'package:go_router/go_router.dart';

import '../../../core/router/rutas.dart';
import 'pages/saldo_del_cliente_page.dart';
import 'pages/tus_tiqueteras_page.dart';
import 'pages/vender_page.dart';

/// Rutas de tiqueteras (EP-05): el saldo y la venta en la caja, y el saldo del cliente
/// en su app. El router de la app las suma con `...rutasDeTiqueteras()`.
List<RouteBase> rutasDeTiqueteras() => [
  GoRoute(
    path: Rutas.saldoDelCliente,
    builder: (_, estado) => SaldoDelClientePage(
      clienteId: estado.pathParameters['clienteId']!,
      nombre: estado.uri.queryParameters['nombre'],
    ),
  ),
  GoRoute(
    path: Rutas.venderTiquetera,
    builder: (_, estado) => VenderPage(
      clienteId: estado.pathParameters['clienteId']!,
      nombre: estado.uri.queryParameters['nombre'],
    ),
  ),
  GoRoute(path: Rutas.tusTiqueteras, builder: (_, _) => const TusTiqueterasPage()),
];
