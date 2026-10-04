import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:veci_api/api.dart';

import '../../features/sesion/data/datasources/almacen_sesion_seguro.dart';
import '../../features/sesion/data/datasources/dispositivo_local.dart';
import '../../features/sesion/data/datasources/eventos_pendientes_sin_outbox.dart';
import '../../features/sesion/data/repositories/sesion_repository_impl.dart';
import '../../features/sesion/domain/entities/estado_sesion.dart';
import '../../features/sesion/domain/usecases/gestor_sesion.dart';
import '../network/cliente_api.dart';
import '../network/cliente_http_sesion.dart';
import 'core_providers.dart';

/// Conecta la sesión (EP-02): servidor, almacén cifrado y cola de pendientes.
final almacenSeguroProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final gestorSesionProvider = Provider<GestorSesion>((ref) {
  final config = ref.watch(apiConfigProvider);
  final seguro = ref.watch(almacenSeguroProvider);
  final repositorio = SesionRepositoryImpl(
    SesionesApi(crearClienteApi(config)),
    (token) => MiCuentaApi(clienteConToken(config, token)),
    DispositivoLocal(seguro),
  );
  final gestor = GestorSesion(
    repositorio,
    AlmacenSesionSeguro(seguro),
    const EventosPendientesSinOutbox(),
  );
  ref.onDispose(gestor.cerrar);
  return gestor;
});

/// La sesión como fuente del token para el cliente HTTP de toda la app.
final fuenteDeTokenProvider = Provider<FuenteDeToken>(
  (ref) => _FuenteGestor(ref.watch(gestorSesionProvider)),
);

class _FuenteGestor implements FuenteDeToken {
  const _FuenteGestor(this._gestor);

  final GestorSesion _gestor;

  @override
  Future<String?> tokenVigente() => _gestor.tokenVigente();

  @override
  Future<String?> renovar() => _gestor.renovar();
}

/// Estado de la sesión para las pantallas; cambia con cada ingreso, renovación o cierre.
final estadoSesionProvider = NotifierProvider<EstadoSesionNotifier, EstadoSesion>(
  EstadoSesionNotifier.new,
);

class EstadoSesionNotifier extends Notifier<EstadoSesion> {
  @override
  EstadoSesion build() {
    final gestor = ref.watch(gestorSesionProvider);
    final suscripcion = gestor.cambios.listen((nuevo) => state = nuevo);
    ref.onDispose(suscripcion.cancel);
    return gestor.estado;
  }
}

/// Negocio con el que se trabaja, o null si aún no lo eligió.
final comercioActivoProvider = Provider<String?>((ref) {
  final estado = ref.watch(estadoSesionProvider);
  return estado is SesionActiva ? estado.comercioId : null;
});
