import { Inject, Injectable } from '@nestjs/common';
import { ID_GENERATOR, IdGenerator } from '../../../../shared/domain/id-generator';
import { POC_TENANTS } from '../../../../shared/domain/poc-tenants';
import { DemoQr, ExpectedScanResult } from '../../domain/demo-qr';
import { QR_CODE_REPOSITORY, QrCodeRepository } from '../../domain/qr-code.repository';
import { SIGNING_KEYRING, SigningKeyring } from '../../domain/signing-keyring';

const VALID_CUSTOMERS = 5;

/**
 * Emite la hoja de QR para probar la caja: clientes válidos, un QR revocado,
 * uno de otro comercio y uno con la firma alterada. Se emite una sola vez por
 * arranque, así la hoja impresa y la lista de revocados que baja el celular coinciden.
 */
@Injectable()
export class EmitirHojaDePruebaUseCase {
  constructor(
    @Inject(SIGNING_KEYRING) private readonly keyring: SigningKeyring,
    @Inject(QR_CODE_REPOSITORY) private readonly codes: QrCodeRepository,
    @Inject(ID_GENERATOR) private readonly ids: IdGenerator,
  ) {}

  private sheet?: DemoQr[];

  execute(): DemoQr[] {
    this.sheet ??= this.issueSheet();
    return this.sheet;
  }

  private issueSheet(): DemoQr[] {
    const sheet: DemoQr[] = [];
    for (let i = 1; i <= VALID_CUSTOMERS; i++) {
      sheet.push(this.issue(`Cliente ${i}`, POC_TENANTS.own, 'VALIDO'));
    }
    sheet.push(this.issue('Cliente con QR revocado', POC_TENANTS.own, 'REVOCADO', true));
    sheet.push(this.issue('Cliente de otro restaurante', POC_TENANTS.other, 'OTRO_COMERCIO'));
    const forged = this.issue('QR con firma alterada', POC_TENANTS.own, 'FIRMA_INVALIDA');
    sheet.push({ ...forged, token: tamperSignature(forged.token) });
    return sheet;
  }

  private issue(label: string, tenantId: string, expected: ExpectedScanResult, revoke = false): DemoQr {
    const qrCodeId = this.ids.next();
    const affiliationId = this.ids.next();
    const revokedAt = revoke ? new Date().toISOString() : null;
    this.codes.save({ id: qrCodeId, tenantId, affiliationId, version: 1, revokedAt });
    const token = this.keyring.signToken({
      keyId: this.keyring.activeKeyId(tenantId),
      tenantId,
      affiliationId,
      qrCodeId,
      version: 1,
    });
    return { label, token, expected };
  }
}

/** Cambia el primer carácter de la firma: el contenido sigue legible pero no verifica. */
function tamperSignature(token: string): string {
  const cut = token.lastIndexOf('.') + 1;
  const first = token.charAt(cut) === 'A' ? 'B' : 'A';
  return token.slice(0, cut) + first + token.slice(cut + 1);
}
