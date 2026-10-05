import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../../features/mi_qr/data/datasources/copia_mi_qr.dart';
import '../../features/mi_qr/data/repositories/mi_qr_repository_impl.dart';
import '../../features/mi_qr/domain/repositories/mi_qr_repository.dart';
import '../../features/sesion/domain/entities/estado_sesion.dart';
import 'core_providers.dart';
import 'sesion_providers.dart';

/// Conecta Mi QR y Tus negocios (HU-04-02, HU-04-03): la API con sesión y la copia
/// cifrada en el celular.
final miQrRepositoryProvider = Provider<MiQrRepository>(
  (ref) => MiQrRepositoryImpl(
    RegistroDelClienteApi(ref.watch(clienteApiProvider)),
    CopiaMiQr(CajonSeguro(ref.watch(almacenSeguroProvider))),
  ),
);

/// Nombre de quien tiene la sesión, para ponerlo debajo de su QR.
final nombreDeLaPersonaProvider = Provider<String>((ref) {
  final estado = ref.watch(estadoSesionProvider);
  return estado is SesionActiva ? estado.sesion.nombre : '';
});

/// Quien solo es cliente tiene Mi QR o Tus negocios como inicio; puede registrar su negocio.
final soloClienteProvider = Provider<bool>((ref) {
  final estado = ref.watch(estadoSesionProvider);
  return estado is SesionActiva && estado.soloCliente;
});
