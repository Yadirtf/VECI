import { Inject, Injectable } from '@nestjs/common';
import { POC_TENANTS } from '../../../../shared/domain/poc-tenants';
import { QR_CODE_REPOSITORY, QrCodeRepository } from '../../domain/qr-code.repository';
import { PublicSigningKey, SIGNING_KEYRING, SigningKeyring } from '../../domain/signing-keyring';

export interface DatosOffline {
  tenantId: string;
  signingKeys: PublicSigningKey[];
  revokedQrCodeIds: string[];
}

/**
 * Lo que el celular del cajero baja para validar QR sin internet:
 * claves públicas del comercio y lista de QR revocados (bajada de la sección 5).
 */
@Injectable()
export class ObtenerDatosOfflineUseCase {
  constructor(
    @Inject(SIGNING_KEYRING) private readonly keyring: SigningKeyring,
    @Inject(QR_CODE_REPOSITORY) private readonly codes: QrCodeRepository,
  ) {}

  execute(): DatosOffline {
    const tenantId = POC_TENANTS.own;
    return {
      tenantId,
      signingKeys: this.keyring.publicKeys(tenantId),
      revokedQrCodeIds: this.codes.revoked(tenantId).map((c) => c.id),
    };
  }
}
