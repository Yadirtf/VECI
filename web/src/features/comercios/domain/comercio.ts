/** Servicio con que nace un tipo de negocio, con su horario sugerido. */
export interface ServicioSugerido {
  nombre: string;
  horaInicio: string;
  horaFin: string;
}

export interface TipoDeNegocio {
  codigo: string;
  nombre: string;
  servicios: ServicioSugerido[];
}

export interface Municipio {
  id: number;
  nombre: string;
}

export interface DatosAlta {
  nombre: string;
  tipoNegocio: string;
  tipoDocumento: 'NIT' | 'CC';
  numeroDocumento: string;
  celular: string;
  correo: string | null;
  municipioId: number | null;
  direccion: string | null;
}

/** Pedido de registro que revisa Administración VECI (ADR-0019). */
export interface Solicitud {
  solicitudId: string;
  estado: 'PENDING' | 'APPROVED' | 'REJECTED';
  nombre: string;
  municipio: string;
  /** Por qué se rechazó. */
  nota: string | null;
  comercioId: string | null;
  radicadaEn: string;
}

export type CodigoPaso = 'DATOS' | 'HORARIOS' | 'EQUIPO' | 'TIQUETERAS';

export interface Perfil {
  comercioId: string;
  nombre: string;
  slug: string;
  tipoNegocio: string;
  documento: { tipo: string; numero: string };
  celular: string | null;
  correo: string | null;
  logoUrl: string | null;
  abierto: boolean;
  plan: { nombre: string; codigo: string; venceEl: string } | null;
  camino: { codigo: CodigoPaso; listo: boolean; obligatorio: boolean }[];
  puedeAbrir: boolean;
}

export interface CambiosPerfil {
  nombre?: string;
  celular?: string;
  correo?: string | null;
  logoUrl?: string | null;
}

/** Comercios en el API; la infraestructura decide cómo llegar. */
export interface RepositorioComercios {
  tipos(): Promise<TipoDeNegocio[]>;
  municipios(): Promise<Municipio[]>;
  /** Pide a VECI registrar el negocio; nace cuando Administración VECI lo aprueba. */
  solicitar(datos: DatosAlta): Promise<void>;
  misSolicitudes(): Promise<Solicitud[]>;
  perfil(): Promise<Perfil>;
  editar(cambios: CambiosPerfil): Promise<Perfil>;
  abrir(): Promise<Perfil>;
}
