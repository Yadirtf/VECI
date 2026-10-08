import { AlcanceDeCuenta } from '../../domain/rules/alcance-de-cuenta.rule';

/** Lee a qué negocios y roles de VECI llega una cuenta, sin importar desde dónde se pida. */
export interface AlcanceDeCuentas {
  /** comercioId: negocio desde el que se pide (no cuenta como "otro"); null = VECI. */
  de(usuarioId: string, comercioId: string | null): Promise<AlcanceDeCuenta>;
}

export const ALCANCE_DE_CUENTAS = Symbol('AlcanceDeCuentas');
