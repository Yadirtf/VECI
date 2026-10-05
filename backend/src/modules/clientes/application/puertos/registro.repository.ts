import { EstadoCuenta } from '../../domain/entities/cliente';

/** Datos de quien se registra solo en la app (HU-04-01), ya validados. */
export interface RegistroPropio {
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
  /** Celular en E.164; queda como contacto y como identificador para entrar. */
  celular: string;
  hashPin: string;
  politicaVersionId: string;
  ip: string | null;
}

/** Tipo de documento para personas (core.document_types) con su forma válida. */
export interface TipoDeDocumento {
  codigo: string;
  nombre: string;
  /** Expresión regular del catálogo (ADR-0006); null = cualquier texto. */
  patron: string | null;
}

/**
 * Altas de personas en toda la plataforma, sin comercio. Solo responde si un dato ya
 * tiene cuenta: nunca dice de quién es ni en qué negocios está.
 */
export interface RegistroRepository {
  tiposDeDocumento(): Promise<TipoDeDocumento[]>;
  /** Estado de la cuenta que entra con ese celular; null si nadie lo usa. */
  cuentaPorCelular(celular: string): Promise<Exclude<EstadoCuenta, 'SIN_CUENTA'> | null>;
  /** Estado de la cuenta de la persona con ese documento; null si no existe. */
  cuentaPorDocumento(tipo: string, numero: string): Promise<EstadoCuenta | null>;
  /**
   * Persona, celular, usuario activo, PIN, consentimiento (canal app) y QR personal
   * versión 1, en una transacción. Devuelve el usuario creado.
   */
  registrar(registro: RegistroPropio): Promise<{ usuarioId: string; personaId: string }>;
}

export const REGISTRO_REPOSITORY = Symbol('RegistroRepository');
