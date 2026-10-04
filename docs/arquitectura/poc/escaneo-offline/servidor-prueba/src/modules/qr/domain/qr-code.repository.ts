export interface IssuedQrCode {
  id: string;
  tenantId: string;
  affiliationId: string;
  version: number;
  revokedAt: string | null;
}

/** Registro de QR emitidos y revocados (customers.affiliation_qr_codes). */
export interface QrCodeRepository {
  save(code: IssuedQrCode): void;
  revoked(tenantId: string): IssuedQrCode[];
}

export const QR_CODE_REPOSITORY = Symbol('QrCodeRepository');
