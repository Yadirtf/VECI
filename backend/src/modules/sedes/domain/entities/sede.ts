/** Sede o local del negocio (RF-COM-03). Todo negocio nace con su sede principal. */
export interface Sede {
  readonly sedeId: string;
  readonly nombre: string;
  readonly principal: boolean;
  /** Código del estado (ACTIVE, INACTIVE) y si con él se puede operar. */
  readonly estado: string;
  readonly activa: boolean;
  readonly municipioId: number | null;
  readonly municipio: string | null;
  readonly direccion: string | null;
}

/** Cajero y las sedes donde trabaja. Sin sedes asignadas trabaja en todas. */
export interface CajeroEnSedes {
  readonly membresiaId: string;
  readonly nombre: string;
  readonly sedeIds: readonly string[];
}

/** Lo que el plan deja tener: varias sedes (función MULTI_BRANCH) y cuántas como máximo. */
export interface CupoDeSedes {
  readonly ocupadas: number;
  readonly limite: number | null;
  readonly variasSedes: boolean;
}
