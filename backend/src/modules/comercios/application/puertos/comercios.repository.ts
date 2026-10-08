import { PerfilComercio } from '../../domain/entities/comercio';
import { DocumentoNegocio } from '../../domain/value-objects/documento-negocio.vo';
import { NombreNegocio } from '../../domain/value-objects/nombre-negocio.vo';

/** Servicio con que nace un tipo de negocio y su horario sugerido. */
export interface ServicioSugerido {
  nombre: string;
  horaInicio: string;
  horaFin: string;
}

/** Tipo de negocio del catálogo tenancy.business_types (RF-COM-04). */
export interface TipoDeNegocio {
  codigo: string;
  nombre: string;
  servicios: ServicioSugerido[];
}

export interface Municipio {
  id: number;
  nombre: string;
}

/** Todo lo que se crea en una sola transacción al registrar un negocio (HU-03-01). */
export interface AltaDeComercio {
  comercioId: string;
  nombre: NombreNegocio;
  documento: DocumentoNegocio;
  tipoNegocio: string;
  celular: string;
  correo: string | null;
  logoUrl: string | null;
  municipioId: number | null;
  direccion: string | null;
  /** Usuario que queda como propietario activo; null si VECI lo invita después. */
  propietarioId: string | null;
  creadoPor: string;
}

export interface CambiosComercio {
  nombre?: NombreNegocio;
  tipoNegocio?: string;
  celular?: string;
  correo?: string | null;
  logoUrl?: string | null;
}

/** Comercios. Salvo registrar, todo actúa sobre el comercio activo (RLS). */
export interface ComerciosRepository {
  tiposDeNegocio(): Promise<TipoDeNegocio[]>;
  /** Solo los municipios donde VECI opera (cobertura). */
  municipios(): Promise<Municipio[]>;
  /** Comercio, sede principal, servicios, plan de prueba y propietario. Devuelve el slug. */
  registrar(alta: AltaDeComercio): Promise<string>;
  perfil(): Promise<PerfilComercio>;
  actualizar(cambios: CambiosComercio): Promise<void>;
  /** Pasa el comercio del estado inicial al que permite operar. */
  abrir(): Promise<void>;
}

export const COMERCIOS_REPOSITORY = Symbol('ComerciosRepository');
