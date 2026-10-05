import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/clientes_providers.dart';
import '../../domain/entities/ficha_cliente.dart';

/// La ficha de un cliente del negocio activo (GET /clientes/{id}).
final fichaClienteProvider = FutureProvider.autoDispose.family<FichaCliente, String>(
  (ref, clienteId) => ref.watch(clientesRepositoryProvider).ficha(clienteId),
);
