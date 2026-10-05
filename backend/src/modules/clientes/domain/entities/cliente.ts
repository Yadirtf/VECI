/** Estado de la afiliación (catálogo customers.affiliation_statuses). */
export type EstadoAfiliacion = 'ACTIVE' | 'BLOCKED' | 'ENDED';

/** Cómo llegó el cliente (customers.affiliation_channels). */
export type CanalAfiliacion = 'PERSONAL_QR_SCAN' | 'ASSISTED_REGISTRATION' | 'DATA_IMPORT';

/**
 * Si la persona puede entrar a la app: ya creó su PIN, la anotaron y espera su PIN de
 * bienvenida, o no tiene cuenta (su celular es de contacto, compartido con otra persona).
 */
export type EstadoCuenta = 'ACTIVA' | 'PENDIENTE' | 'SIN_CUENTA';

/**
 * Un cliente del comercio: la persona (global) vista desde su afiliación (HU-04-03).
 * Lleva los datos completos; la presentación los enmascara según el permiso de quien mira.
 */
export interface Cliente {
  readonly clienteId: string;
  readonly personaId: string;
  readonly nombres: string;
  readonly apellidos: string | null;
  readonly tipoDocumento: string;
  readonly numeroDocumento: string;
  readonly celular: string | null;
  readonly cuenta: EstadoCuenta;
  readonly estado: EstadoAfiliacion;
  readonly canal: CanalAfiliacion;
  readonly afiliadoEn: Date;
}

/** Persona que el cajero va a afiliar, vista solo enmascarada: aún no es su cliente. */
export interface PersonaPorAfiliar {
  readonly personaId: string;
  readonly nombre: string;
  readonly documento: string;
  /** Si ya es cliente de este negocio, su afiliación. */
  readonly clienteId: string | null;
}
