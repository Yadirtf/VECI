import { leerTokenQr } from '../../domain/value-objects/token-qr.vo';
import { ClientesRepository, VistaPreviaQrPersonal } from '../puertos/clientes.repository';
import { TokensQr } from './tokens-qr';

/** Qué es lo que escaneó la caja, en el orden de ADR-0011: forma → comercio → firma → vigencia. */
export type QrEscaneado =
  | { tipo: 'PERSONAL'; previa: VistaPreviaQrPersonal }
  | { tipo: 'CLIENTE'; clienteId: string }
  | { tipo: 'QR_CAMBIADO' | 'OTRO_NEGOCIO' | 'NO_ES_DE_VECI' };

/** Lee un QR en la caja sin mostrar nada de la persona hasta saber que el QR es válido. */
export class LectorQr {
  constructor(
    private readonly clientes: ClientesRepository,
    private readonly tokens: TokensQr,
  ) {}

  async leer(comercioId: string, texto: string): Promise<QrEscaneado> {
    const token = leerTokenQr(texto);
    if (token.tipo === 'AJENO') return { tipo: 'NO_ES_DE_VECI' };
    if (token.tipo === 'AFILIACION') {
      const { carga } = token;
      if (carga.t !== comercioId) return { tipo: 'OTRO_NEGOCIO' };
      if (!this.tokens.esAutentico(token.firmado, token.firma, comercioId, carga.k)) {
        return { tipo: 'NO_ES_DE_VECI' };
      }
      const qr = await this.clientes.qrDeAfiliacion(carga.q);
      if (!qr || qr.clienteId !== carga.a) return { tipo: 'NO_ES_DE_VECI' };
      if (!qr.vigente || qr.version !== carga.v) return { tipo: 'QR_CAMBIADO' };
      return { tipo: 'CLIENTE', clienteId: qr.clienteId };
    }
    const { carga } = token;
    if (!this.tokens.esAutentico(token.firmado, token.firma, null, carga.k)) {
      return { tipo: 'NO_ES_DE_VECI' };
    }
    const previa = await this.clientes.vistaPreviaQrPersonal(carga.q);
    if (!previa) return { tipo: 'NO_ES_DE_VECI' };
    if (!previa.vigente || previa.version !== carga.v) return { tipo: 'QR_CAMBIADO' };
    return { tipo: 'PERSONAL', previa };
  }
}
