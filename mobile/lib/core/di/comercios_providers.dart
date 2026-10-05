import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veci_api/api.dart';

import '../../features/comercios/data/repositories/comercios_repository_impl.dart';
import '../../features/comercios/domain/repositories/comercios_repository.dart';
import 'core_providers.dart';

/// Conecta el alta de negocios desde el celular (EP-03).
final comerciosRepositoryProvider = Provider<ComerciosRepository>(
  (ref) => ComerciosRepositoryImpl(ComerciosApi(ref.watch(clienteApiProvider))),
);
