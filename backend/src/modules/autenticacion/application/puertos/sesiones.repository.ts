/** Plataformas del catálogo identity.device_platforms. */
export type Plataforma = 'ANDROID' | 'IOS' | 'WEB';

/** Celular o navegador; el id (UUID v7) lo genera el propio dispositivo. */
export interface Dispositivo {
  id: string;
  plataforma: Plataforma;
  modelo?: string | null;
  versionSo?: string | null;
  versionApp?: string | null;
}

export interface SesionGuardada {
  id: string;
  usuarioId: string;
  dispositivoId: string;
  huella: string;
  expiraEn: Date;
  cerrada: boolean;
}

/** Motivos de identity.session_revocation_reasons. */
export type MotivoCierre = 'LOGOUT' | 'REMOTE_LOGOUT' | 'CREDENTIAL_RESET' | 'TOKEN_REUSE_DETECTED';

export interface NuevaSesion {
  id: string;
  usuarioId: string;
  dispositivoId: string;
  huella: string;
  expiraEn: Date;
}

/** Sesiones por dispositivo con token de renovación guardado como huella. */
export interface SesionesRepository {
  registrarDispositivo(dispositivo: Dispositivo): Promise<void>;
  crear(sesion: NuevaSesion): Promise<void>;
  buscar(sesionId: string): Promise<SesionGuardada | null>;
  /** Cambia la huella solo si sigue siendo la anterior (evita dos renovaciones con un token). */
  rotar(
    sesionId: string,
    huellaAnterior: string,
    huellaNueva: string,
    expiraEn: Date,
  ): Promise<boolean>;
  cerrar(sesionId: string, motivo: MotivoCierre, porUsuarioId: string | null): Promise<void>;
  cerrarTodasDe(
    usuarioId: string,
    motivo: MotivoCierre,
    porUsuarioId: string | null,
  ): Promise<number>;
}

export const SESIONES_REPOSITORY = Symbol('SesionesRepository');
