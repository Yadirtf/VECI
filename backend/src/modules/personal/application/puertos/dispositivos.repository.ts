/** Sesión abierta de alguien del equipo en un dispositivo del negocio. */
export interface SesionEnDispositivo {
  sesionId: string;
  usuarioId: string;
  nombre: string;
  abiertaDesde: Date;
  ultimoUso: Date;
}

/** Celular registrado como caja del negocio (tenancy.tenant_devices). */
export interface DispositivoDelNegocio {
  dispositivoId: string;
  nombre: string | null;
  plataforma: string;
  registradoEn: Date;
  ultimaVez: Date;
  sesiones: SesionEnDispositivo[];
}

export interface DispositivosRepository {
  listar(): Promise<DispositivoDelNegocio[]>;
  existe(dispositivoId: string): Promise<boolean>;
  /** Cierra las sesiones del equipo de este negocio en ese dispositivo. Devuelve cuántas. */
  cerrarSesiones(dispositivoId: string, porUsuarioId: string): Promise<number>;
}

export const DISPOSITIVOS_REPOSITORY = Symbol('DispositivosRepository');
