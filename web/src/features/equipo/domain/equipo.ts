export type EstadoMiembro = 'INVITED' | 'ACTIVE' | 'SUSPENDED' | 'REMOVED';
export type AccionMiembro = 'SUSPENDER' | 'REACTIVAR' | 'RETIRAR';

/** Persona del equipo del negocio: propietario o cajero. */
export interface Miembro {
  membresiaId: string;
  usuarioId: string;
  nombre: string;
  celular: string | null;
  estado: EstadoMiembro;
  roles: readonly string[];
}

export interface DatosInvitacion {
  celular: string;
  nombres: string;
  apellidos?: string;
  tipoDocumento: string;
  numeroDocumento: string;
}

export interface Invitacion {
  membresiaId: string;
  /** Se muestra una sola vez. null si la persona ya tenía PIN propio en VECI. */
  pinTemporal: string | null;
}

export interface SesionEnDispositivo {
  sesionId: string;
  nombre: string;
  ultimoUso: Date;
}

export interface Dispositivo {
  dispositivoId: string;
  nombre: string | null;
  plataforma: string;
  ultimaVez: Date;
  sesiones: readonly SesionEnDispositivo[];
}

/** Equipo y dispositivos del negocio activo; la infraestructura decide de dónde salen. */
export interface RepositorioEquipo {
  listar(): Promise<Miembro[]>;
  invitar(datos: DatosInvitacion): Promise<Invitacion>;
  cambiarEstado(membresiaId: string, accion: AccionMiembro): Promise<void>;
  restablecerPin(membresiaId: string): Promise<string>;
  dispositivos(): Promise<Dispositivo[]>;
  cerrarSesiones(dispositivoId: string): Promise<number>;
}
