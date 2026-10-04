import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/horarios/presentation/pages/horarios_page.dart';
import '../../features/inicio/presentation/pages/inicio_page.dart';
import '../../features/inicio/presentation/pages/muestrario_page.dart';
import '../../features/sesion/domain/entities/estado_sesion.dart';
import '../../features/sesion/domain/reglas/reglas_ingreso.dart';
import '../../features/sesion/domain/usecases/gestor_sesion.dart';
import '../../features/sesion/presentation/pages/elegir_negocio_page.dart';
import '../../features/sesion/presentation/pages/entrar_page.dart';
import '../../features/sesion/presentation/pages/pin_nuevo_page.dart';
import 'redireccion.dart';
import 'rutas.dart';

/// Avisa a go_router cada vez que cambia la sesión, para volver a decidir la pantalla.
class _CambiosDeSesion extends ChangeNotifier {
  _CambiosDeSesion(GestorSesion gestor) {
    gestor.cambios.listen((_) => notifyListeners());
  }
}

/// Navegación de la app (go_router, sección 6.1). Sin sesión o sin negocio, la app
/// lleva a entrar, crear el PIN o elegir el negocio (EP-02).
GoRouter crearRouter(GestorSesion gestor) => GoRouter(
  initialLocation: Rutas.cargando,
  refreshListenable: _CambiosDeSesion(gestor),
  redirect: (_, estadoRuta) => redirigir(gestor.estado, estadoRuta.matchedLocation),
  routes: [
    GoRoute(path: Rutas.cargando, builder: (_, _) => const _Cargando()),
    GoRoute(path: Rutas.entrar, builder: (_, _) => const EntrarPage()),
    GoRoute(path: Rutas.pinNuevo, builder: (_, _) => const PinNuevoPage()),
    GoRoute(path: Rutas.negocio, builder: (_, _) => const ElegirNegocioPage()),
    GoRoute(path: Rutas.inicio, builder: (_, _) => _inicio(gestor)),
    GoRoute(path: Rutas.horarios, builder: (_, _) => const HorariosPage()),
    GoRoute(path: Rutas.disenio, builder: (_, _) => const MuestrarioPage()),
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
  );
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
