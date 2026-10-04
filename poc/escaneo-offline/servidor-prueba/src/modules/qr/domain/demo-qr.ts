/** Qué debe responder la caja al escanear cada QR de la hoja de prueba. */
export type ExpectedScanResult = 'VALIDO' | 'REVOCADO' | 'OTRO_COMERCIO' | 'FIRMA_INVALIDA';

export interface DemoQr {
  label: string;
  token: string;
  expected: ExpectedScanResult;
}
