/** Comprueba que la base de datos responde. */
export interface SondaBaseDatos {
  responde(): Promise<boolean>;
}

export const SONDA_BASE_DATOS = Symbol('SondaBaseDatos');
