import { IssuedQrCode, QrCodeRepository } from '../domain/qr-code.repository';

export class InMemoryQrCodeRepository implements QrCodeRepository {
  private readonly codes = new Map<string, IssuedQrCode>();

  save(code: IssuedQrCode): void {
    this.codes.set(code.id, code);
  }

  revoked(tenantId: string): IssuedQrCode[] {
    return [...this.codes.values()].filter((c) => c.tenantId === tenantId && c.revokedAt !== null);
  }
}
