import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/escaneo/data/repositories/consumption_outbox_impl.dart';
import '../../features/escaneo/data/repositories/offline_trust_repository_impl.dart';
import '../../features/escaneo/data/services/ed25519_signature_verifier.dart';
import '../../features/escaneo/domain/repositories/consumption_outbox.dart';
import '../../features/escaneo/domain/repositories/offline_trust_repository.dart';
import '../../features/escaneo/domain/usecases/generar_consumos_de_prueba.dart';
import '../../features/escaneo/domain/usecases/registrar_consumo_por_qr.dart';
import '../../features/escaneo/domain/usecases/validar_qr.dart';
import 'core_providers.dart';

final offlineTrustRepositoryProvider = Provider<OfflineTrustRepository>(
  (ref) => OfflineTrustRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final consumptionOutboxProvider = Provider<ConsumptionOutbox>(
  (ref) => ConsumptionOutboxImpl(ref.watch(outboxDaoProvider)),
);

final validarQrProvider = Provider<ValidarQr>(
  (ref) => ValidarQr(
    trust: ref.watch(offlineTrustRepositoryProvider),
    verifier: Ed25519SignatureVerifier(),
  ),
);

final registrarConsumoPorQrProvider = Provider<RegistrarConsumoPorQr>(
  (ref) => RegistrarConsumoPorQr(
    validar: ref.watch(validarQrProvider),
    outbox: ref.watch(consumptionOutboxProvider),
    ids: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider),
  ),
);

final generarConsumosDePruebaProvider = Provider<GenerarConsumosDePrueba>(
  (ref) => GenerarConsumosDePrueba(
    outbox: ref.watch(consumptionOutboxProvider),
    trust: ref.watch(offlineTrustRepositoryProvider),
    ids: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider),
  ),
);
