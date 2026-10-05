/** Paso del camino para abrir el negocio (HU-03-01): lo que ya está y lo que falta. */
export interface PasoDelCamino {
  readonly codigo: 'DATOS' | 'HORARIOS' | 'EQUIPO' | 'TIQUETERAS';
  readonly listo: boolean;
  /** Si falta, ¿impide abrir? */
  readonly obligatorio: boolean;
}

/** Cuánto está configurado el negocio, contado en la base. */
export interface Avance {
  readonly serviciosConHorario: number;
  readonly cajeros: number;
  readonly tiqueteras: number;
}

export interface Contacto {
  readonly celular: string | null;
  readonly correo: string | null;
}

export interface PlanActual {
  readonly codigo: string;
  readonly nombre: string;
  readonly estado: string;
  readonly venceEl: string;
}

/** Datos del negocio activo tal como los ve su propietario. */
export interface PerfilComercio {
  readonly comercioId: string;
  readonly nombre: string;
  readonly slug: string;
  readonly tipoNegocio: string;
  readonly documento: { tipo: string; numero: string };
  readonly contacto: Contacto;
  readonly logoUrl: string | null;
  readonly estado: string;
  /** El estado deja vender y registrar consumos (columna allows_operations). */
  readonly abierto: boolean;
  readonly plan: PlanActual | null;
  readonly avance: Avance;
}
