import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../../features/registro/data/repositories/registro_repository_impl.dart';
import '../../features/registro/domain/repositories/registro_repository.dart';
import '../../features/sesion/data/datasources/dispositivo_local.dart';
import '../../features/sesion/data/repositories/sesion_repository_impl.dart';
import '../network/cliente_api.dart';
import 'core_providers.dart';
import 'sesion_providers.dart';

/// Conecta el registro del cliente (HU-04-01): la API sin sesión, este celular como
/// dispositivo y, al terminar, la sesión nueva en el gestor de la app.
final registroRepositoryProvider = Provider<RegistroRepository>((ref) {
  final gestor = ref.watch(gestorSesionProvider);
  final reloj = ref.watch(relojProvider);
  return RegistroRepositoryImpl(
    RegistroDelClienteApi(crearClienteApi(ref.watch(apiConfigProvider))),
    DispositivoLocal(ref.watch(almacenSeguroProvider)).describir,
    (sesion) => gestor.entrarConSesionNueva(sesionDesdeRespuesta(sesion, reloj())),
  );
});
