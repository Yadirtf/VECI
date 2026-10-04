import { Module } from '@nestjs/common';
import { ID_GENERATOR } from '../../shared/domain/id-generator';
import { UuidV7Generator } from '../../shared/infrastructure/uuid-v7.generator';
import { EmitirHojaDePruebaUseCase } from './application/use-cases/emitir-hoja-de-prueba.use-case';
import { ObtenerDatosOfflineUseCase } from './application/use-cases/obtener-datos-offline.use-case';
import { QR_CODE_REPOSITORY } from './domain/qr-code.repository';
import { SIGNING_KEYRING } from './domain/signing-keyring';
import { Ed25519Keyring } from './infrastructure/ed25519-keyring';
import { InMemoryQrCodeRepository } from './infrastructure/in-memory-qr-code.repository';
import { QrController } from './presentation/http/qr.controller';

@Module({
  controllers: [QrController],
  providers: [
    EmitirHojaDePruebaUseCase,
    ObtenerDatosOfflineUseCase,
    { provide: SIGNING_KEYRING, useClass: Ed25519Keyring },
    { provide: QR_CODE_REPOSITORY, useClass: InMemoryQrCodeRepository },
    { provide: ID_GENERATOR, useClass: UuidV7Generator },
  ],
})
export class QrModule {}
