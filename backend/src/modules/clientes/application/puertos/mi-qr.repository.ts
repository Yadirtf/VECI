import { ClaveDelComercio } from './clientes.repository';

/** Versión vigente del QR personal (customers.personal_qr_codes). */
export interface QrPersonalGuardado {
  qrId: string;
  version: number;
  emitidoEn: Date;
}

/** QR del cliente en un comercio, con lo necesario para volver a armar su token. */
export interface QrDeAfiliacionGuardado {
  qrId: string;
  version: number;
  keyId: string;
}

/** Un negocio donde la persona es cliente, visto desde su app (HU-04-03). */
export interface ComercioDelCliente {
  comercioId: string;
  clienteId: string;
  nombre: string;
  tipoNegocio: string;
  afiliadoEn: Date;
  qr: QrDeAfiliacionGuardado | null;
}

/** Lo propio del cliente en su app: contexto de la persona (app.person_id, RLS). */
export interface MiQrRepository {
  /** Persona del usuario de la sesión. */
  personaDe(usuarioId: string): Promise<string>;
  vigente(personaId: string): Promise<QrPersonalGuardado | null>;
  /** Crea la versión 1 si aún no tiene (cliente registrado en la caja que activa su app). */
  emitirPrimero(personaId: string): Promise<QrPersonalGuardado>;
  /** Revoca el vigente (REGENERATED) y emite la versión siguiente, en una transacción. */
  regenerar(personaId: string): Promise<QrPersonalGuardado>;
  comercios(usuarioId: string, personaId: string): Promise<ComercioDelCliente[]>;
  /**
   * Emite el QR del cliente en ese comercio cuando su afiliación no tiene uno vigente
   * (afiliaciones de la semilla, importadas o que llegan sin señal). Idempotente.
   */
  emitirQrDeAfiliacion(
    en: { comercioId: string; usuarioId: string },
    clienteId: string,
    clave: ClaveDelComercio,
  ): Promise<QrDeAfiliacionGuardado>;
}

export const MI_QR_REPOSITORY = Symbol('MiQrRepository');
