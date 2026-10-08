/** Unidad que se descuenta (catálogo prepaid.consumption_units): almuerzo, café, pan. */
export interface UnidadDeConsumo {
  readonly codigo: string;
  readonly singular: string;
  readonly plural: string;
}

/** Estado del tipo (prepaid.package_type_statuses): solo el activo se vende. */
export type EstadoTipo = 'ACTIVE' | 'INACTIVE' | 'ARCHIVED';

/**
 * Paquete que el negocio ofrece (HU-05-01): "20 almuerzos por $220.000, sirve 30 días".
 * Desactivarlo o cambiar su precio no toca lo vendido: cada venta guarda lo que se cobró.
 */
export interface TipoDeTiquetera {
  readonly tipoId: string;
  readonly nombre: string;
  readonly unidad: UnidadDeConsumo;
  readonly unidades: number;
  /** Pesos colombianos, sin centavos. */
  readonly precio: number;
  readonly vigenciaDias: number;
  readonly estado: EstadoTipo;
  /** Tiqueteras de este tipo que se han vendido, y las que siguen con unidades por servir. */
  readonly vendidas: number;
  readonly vigentes: number;
}

/** Lo que el propietario escribe al crear o cambiar un tipo. */
export interface DatosDeTipo {
  readonly nombre: string;
  readonly unidad: string;
  readonly unidades: number;
  readonly precio: number;
  readonly vigenciaDias: number;
}
