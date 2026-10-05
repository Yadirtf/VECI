import 'package:go_router/go_router.dart';

import 'pages/escanear_qr_page.dart';
import 'pages/ficha_cliente_page.dart';
import 'pages/ranura_page.dart';
import 'pages/registro_asistido_page.dart';

/// Rutas de los clientes en la caja (EP-04). El router de la app las suma con
/// `...rutasDeClientes()`; cada pantalla saca el negocio activo y la API de core/di.
abstract final class RutasClientes {
  /// "La ranura de quien sigue": buscar, escanear o registrar.
  static const caja = '/caja';
  static const escanear = '/caja/escanear';

  /// Registro asistido; `?dato=` trae lo escrito en la ranura.
  static const registrar = '/caja/registrar';

  /// Ficha de un cliente: `/caja/clientes/{clienteId}`, con `?aviso=` opcional.
  static const ficha = '/caja/clientes/:clienteId';

  static String registrarCon(String dato) =>
      Uri(path: registrar, queryParameters: dato.isEmpty ? null : {'dato': dato}).toString();

  static String fichaDe(String clienteId, {AvisoFicha? aviso}) => Uri(
    path: '/caja/clientes/$clienteId',
    queryParameters: aviso == null ? null : {'aviso': aviso.name},
  ).toString();
}

List<RouteBase> rutasDeClientes() => [
  GoRoute(
    path: RutasClientes.caja,
    builder: (_, _) => const RanuraPage(),
    routes: [
      GoRoute(path: 'escanear', builder: (_, _) => const EscanearQrPage()),
      GoRoute(
        path: 'registrar',
        builder: (_, estado) =>
            RegistroAsistidoPage(datoInicial: estado.uri.queryParameters['dato'] ?? ''),
      ),
      GoRoute(
        path: 'clientes/:clienteId',
        builder: (_, estado) => FichaClientePage(
          clienteId: estado.pathParameters['clienteId']!,
          aviso: AvisoFicha.values.asNameMap()[estado.uri.queryParameters['aviso']],
        ),
      ),
    ],
  ),
];
