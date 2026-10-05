import { PasoDelCamino, PerfilComercio } from '../../domain/entities/comercio';

export interface RegistrarComercioInput {
  nombre: string;
  tipoNegocio: string;
  tipoDocumento: string;
  numeroDocumento: string;
  celular: string;
  correo?: string | null;
  logoUrl?: string | null;
  municipioId?: number | null;
  direccion?: string | null;
}

export interface ComercioRegistradoOutput {
  comercioId: string;
  slug: string;
  /** Solo cuando VECI registra el negocio a nombre de alguien sin PIN propio. */
  pinTemporal?: string | null;
}

export interface EditarComercioInput {
  nombre?: string;
  tipoNegocio?: string;
  celular?: string;
  correo?: string | null;
  logoUrl?: string | null;
}

export interface PerfilOutput extends PerfilComercio {
  camino: PasoDelCamino[];
  puedeAbrir: boolean;
}
