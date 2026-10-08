import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/clientes/presentation/rutas_clientes.dart';
import '../../features/comercios/presentation/pages/ajustes_page.dart';
import '../../features/comercios/presentation/pages/alta_negocio_page.dart';
import '../../features/horarios/presentation/pages/horarios_page.dart';
import '../../features/inicio/presentation/pages/inicio_page.dart';
import '../../features/inicio/presentation/pages/muestrario_page.dart';
import '../../features/mi_qr/presentation/pages/mi_qr_page.dart';
import '../../features/mi_qr/presentation/pages/qr_en_negocio_page.dart';
import '../../features/mi_qr/presentation/pages/tus_negocios_page.dart';
import '../../features/registro/presentation/pages/politica_page.dart';
import '../../features/registro/presentation/pages/registro_page.dart';
import '../../features/sesion/domain/entities/estado_sesion.dart';
import '../../features/sesion/domain/reglas/reglas_ingreso.dart';
import '../../features/sesion/domain/usecases/gestor_sesion.dart';
import '../../features/sesion/presentation/pages/elegir_negocio_page.dart';
import '../../features/sesion/presentation/pages/entrar_page.dart';
import '../../features/sesion/presentation/pages/pin_nuevo_page.dart';
import '../../features/tiqueteras/presentation/rutas_tiqueteras.dart';
import 'redireccion.dart';
import 'rutas.dart';

/// Avisa a go_router cada vez que cambia la sesión, para volver a decidir la pantalla.
class _CambiosDeSesion extends ChangeNotifier {
  _CambiosDeSesion(GestorSesion gestor) {
    gestor.cambios.listen((_) => notifyListeners());
  }
}

/// Navegación de la app (go_router, sección 6.1). Sin sesión o sin negocio, la app
/// lleva a entrar, crear la cuenta, crear el PIN o elegir el negocio (EP-02, EP-04).
/// Quien solo es cliente tiene como inicio Mi QR o Tus negocios.
GoRouter crearRouter(GestorSesion gestor) => GoRouter(
  initialLocation: Rutas.cargando,
  refreshListenable: _CambiosDeSesion(gestor),
  redirect: (_, estadoRuta) => redirigir(gestor.estado, estadoRuta.matchedLocation),
  routes: [
    GoRoute(path: Rutas.cargando, builder: (_, _) => const _Cargando()),
    GoRoute(
      path: Rutas.entrar,
      builder: (_, estado) => EntrarPage(celular: estado.uri.queryParameters['celular']),
    ),
    GoRoute(path: Rutas.registro, builder: (_, _) => const RegistroPage()),
    GoRoute(path: Rutas.politica, builder: (_, _) => const PoliticaPage()),
    GoRoute(path: Rutas.pinNuevo, builder: (_, _) => const PinNuevoPage()),
    GoRoute(path: Rutas.negocio, builder: (_, _) => const ElegirNegocioPage()),
    GoRoute(path: Rutas.registrarNegocio, builder: (_, _) => const AltaNegocioPage()),
    GoRoute(path: Rutas.ajustes, builder: (_, _) => const AjustesPage()),
    GoRoute(path: Rutas.inicio, builder: (_, _) => _inicio(gestor)),
    GoRoute(path: Rutas.horarios, builder: (_, _) => const HorariosPage()),
    GoRoute(path: Rutas.disenio, builder: (_, _) => const MuestrarioPage()),
    GoRoute(path: Rutas.miQr, builder: (_, _) => const MiQrPage()),
    GoRoute(path: Rutas.tusNegocios, builder: (_, _) => const TusNegociosPage()),
    GoRoute(
      path: Rutas.qrEnNegocio,
      builder: (_, estado) => QrEnNegocioPage(comercioId: estado.pathParameters['comercioId']!),
    ),
    ...rutasDeClientes(),
    ...rutasDeTiqueteras(),
  ],
);

Widget _inicio(GestorSesion gestor) {
  final estado = gestor.estado;
  final negocio = estado is SesionActiva ? estado.negocio : null;
  return InicioPage(
    nombre: estado is SesionActiva ? estado.sesion.nombre : 'veci',
    negocio: negocio?.nombre ?? '',
    enLaCaja: negocio != null && esDeLaCaja(negocio),
    variosNegocios: estado is SesionActiva && estado.sesion.espacios.length > 1,
    alCambiarNegocio: gestor.cambiarDeNegocio,
    alSalir: gestor.salir,
    rutaCaja: RutasClientes.caja,
  );
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
