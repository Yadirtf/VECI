import 'package:go_router/go_router.dart';

import '../../features/horarios/presentation/pages/horarios_page.dart';
import '../../features/inicio/presentation/pages/inicio_page.dart';
import '../../features/inicio/presentation/pages/muestrario_page.dart';
import 'rutas.dart';

/// Navegación de la app (go_router, sección 6.1).
GoRouter crearRouter() => GoRouter(
  initialLocation: Rutas.inicio,
  routes: [
    GoRoute(path: Rutas.inicio, builder: (_, _) => const InicioPage()),
    GoRoute(path: Rutas.horarios, builder: (_, _) => const HorariosPage()),
    GoRoute(path: Rutas.disenio, builder: (_, _) => const MuestrarioPage()),
  ],
);
