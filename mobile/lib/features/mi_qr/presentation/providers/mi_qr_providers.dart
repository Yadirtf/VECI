import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/mi_qr_providers.dart';
import '../../../../core/error/fallo.dart';
import '../../domain/entities/mi_qr.dart';

/// Mi QR: primero lo guardado (al instante, aun sin señal) y luego lo del servidor.
final miQrProvider = StreamProvider.autoDispose<VistaGuardada<MiQr>>((ref) {
  final repositorio = ref.watch(miQrRepositoryProvider);
  return guardadoYAlDia(repositorio.qrGuardado, repositorio.traerQr);
});

/// Negocios donde soy cliente, con mi QR en cada uno.
final misNegociosProvider = StreamProvider.autoDispose<VistaGuardada<List<NegocioDondeSoyCliente>>>(
  (ref) {
    final repositorio = ref.watch(miQrRepositoryProvider);
    return guardadoYAlDia(repositorio.negociosGuardados, repositorio.traerNegocios);
  },
);

/// Sin copia, un fallo de red se muestra; con copia, se sigue mostrando la copia.
Stream<VistaGuardada<T>> guardadoYAlDia<T extends Object>(
  Future<T?> Function() guardado,
  Future<T> Function() traer,
) async* {
  final copia = await guardado();
  if (copia != null) yield VistaGuardada(copia);
  try {
    yield VistaGuardada(await traer());
  } on Fallo catch (fallo) {
    if (copia == null) rethrow;
    yield VistaGuardada(copia, sinSenal: fallo is SinConexion);
  }
}
