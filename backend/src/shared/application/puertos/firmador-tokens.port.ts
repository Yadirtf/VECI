/** Contenido firmado de un token. */
export type CargaToken = Readonly<Record<string, string | number>>;

export type TokenVerificado =
  | { readonly estado: 'valido'; readonly carga: CargaToken }
  | { readonly estado: 'vencido' }
  | { readonly estado: 'invalido' };

/** Firma y verifica tokens de corta duración (acceso y cambio de PIN). */
export interface FirmadorTokens {
  firmar(carga: CargaToken, segundos: number): string;
  verificar(token: string): TokenVerificado;
}

export const FIRMADOR_TOKENS = Symbol('FirmadorTokens');
