import { CanalAfiliacion, Cliente, EstadoCuenta } from '../../domain/entities/cliente';
import { ConsultaDeClientes } from '../../domain/rules/consulta-de-clientes.rule';

/** Persona de VECI vista desde un comercio que aún no la tiene: solo enmascarada. */
export interface PersonaEnVeci {
  personaId: string;
  nombre: string;
  documento: string;
  cuenta: EstadoCuenta;
  /** Si ya es cliente de este comercio. */
  clienteId: string | null;
}

/** Lo que dice el QR personal escaneado, sin abrir los datos de la persona. */
export interface VistaPreviaQrPersonal extends PersonaEnVeci {
  version: number;
  vigente: boolean;
}

/** Clave con que el comercio firma los QR de sus clientes. */
export interface ClaveDelComercio {
  keyId: string;
  publica: Uint8Array;
  referencia: string;
}

/** Persona nueva que el cajero registra (HU-04-04). Sin usuario si el celular es compartido. */
export interface PersonaAsistida {
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
  celular: string;
  conCuenta: boolean;
}

/** Afiliar a una persona existente o nueva; con consentimiento si lo confirmó el cajero. */
export interface NuevaAfiliacion {
  personaId: string | null;
  personaNueva: PersonaAsistida | null;
  canal: CanalAfiliacion;
  actorUsuarioId: string;
  clave: ClaveDelComercio;
  politicaVersionId: string | null;
}

export interface AfiliacionHecha {
  clienteId: string;
  personaId: string;
  /** false si ya era cliente: no se crea nada. */
  nueva: boolean;
  /** Usuario pendiente creado en este registro (para su PIN de bienvenida). */
  usuarioCreado: string | null;
}

/** Copia para buscar sin internet en la caja (HU-04-05). */
export interface CopiaLocal {
  version: string;
  clientes: Cliente[];
  claves: { keyId: string; publica: Uint8Array }[];
}

/** Clientes del comercio activo. Todo corre con el comercio fijado (RLS). */
export interface ClientesRepository {
  vistaPreviaQrPersonal(qrId: string): Promise<VistaPreviaQrPersonal | null>;
  qrDeAfiliacion(
    qrId: string,
  ): Promise<{ clienteId: string; version: number; vigente: boolean } | null>;
  personaPorDocumento(tipo: string, numero: string): Promise<PersonaEnVeci | null>;
  cuentaPorCelular(celular: string): Promise<EstadoCuenta | null>;
  /**
   * Crea lo que falte (persona, usuario pendiente, afiliación, QR versión 1, clave del
   * comercio si es su primer cliente y el consentimiento) en una transacción. Si ya era
   * cliente no crea nada.
   */
  afiliar(afiliacion: NuevaAfiliacion): Promise<AfiliacionHecha>;
  buscar(consulta: ConsultaDeClientes): Promise<Cliente[]>;
  ficha(clienteId: string): Promise<Cliente | null>;
  usuarioDe(clienteId: string): Promise<{ usuarioId: string | null; cuenta: EstadoCuenta } | null>;
  versionDeCopia(): Promise<string>;
  copiaLocal(): Promise<CopiaLocal>;
}

export const CLIENTES_REPOSITORY = Symbol('ClientesRepository');
