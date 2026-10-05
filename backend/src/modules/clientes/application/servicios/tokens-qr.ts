import { FirmadorQr } from '../../../../shared/application/puertos/firmador-qr.port';
import {
  CargaQrAfiliacion,
  CargaQrPersonal,
  parteFirmada,
  PREFIJO_AFILIACION,
  PREFIJO_PERSONAL,
} from '../../domain/value-objects/token-qr.vo';
import { ClaveDelComercio } from '../puertos/clientes.repository';
import { QrDeAfiliacionGuardado, QrPersonalGuardado } from '../puertos/mi-qr.repository';

/** Clave con que VECI firma los QR personales. */
export const CLAVE_VECI = 'p1';
/** Primera clave de cada comercio; rotar es emitir con la siguiente (ADR-0005). */
export const CLAVE_INICIAL_COMERCIO = 'k1';

/**
 * Arma y comprueba los tokens de los QR (ADR-0011, ADR-0017). La firma es
 * determinista: el mismo QR guardado da siempre el mismo token, así la app lo
 * vuelve a pedir sin que cambie el dibujo que el cliente ya conoce.
 */
export class TokensQr {
  constructor(private readonly firmador: FirmadorQr) {}

  personal(qr: QrPersonalGuardado): string {
    const carga: CargaQrPersonal = { k: CLAVE_VECI, q: qr.qrId, v: qr.version };
    return this.firmado(parteFirmada(PREFIJO_PERSONAL, carga), null, CLAVE_VECI);
  }

  afiliacion(comercioId: string, clienteId: string, qr: QrDeAfiliacionGuardado): string {
    const carga: CargaQrAfiliacion = {
      k: qr.keyId,
      t: comercioId,
      a: clienteId,
      q: qr.qrId,
      v: qr.version,
    };
    return this.firmado(parteFirmada(PREFIJO_AFILIACION, carga), comercioId, qr.keyId);
  }

  /** La firma corresponde a la clave que el token dice (de VECI o del comercio). */
  esAutentico(firmado: string, firma: string, comercioId: string | null, keyId: string): boolean {
    return this.firmador.verificar({ comercioId, keyId }, firmado, firma);
  }

  claveDelComercio(comercioId: string, keyId = CLAVE_INICIAL_COMERCIO): ClaveDelComercio {
    return {
      keyId,
      publica: this.firmador.clavePublica({ comercioId, keyId }),
      referencia: this.firmador.referenciaPrivada,
    };
  }

  private firmado(parte: string, comercioId: string | null, keyId: string): string {
    return `${parte}.${this.firmador.firmar({ comercioId, keyId }, parte)}`;
  }
}
