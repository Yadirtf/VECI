/** Cookies del panel. El token de renovación solo lo lee el servidor del panel (httpOnly). */
export const COOKIE_RENOVACION = 'veci_renovacion';
export const COOKIE_DISPOSITIVO = 'veci_dispositivo';

const DIA = 24 * 60 * 60;

export interface CookieBff {
  nombre: string;
  valor: string;
  httpOnly: true;
  sameSite: 'strict' | 'lax';
  secure: boolean;
  path: string;
  maxAge: number;
}

const seguro = () => process.env.NODE_ENV === 'production';

export function cookieRenovacion(valor: string, dias: number): CookieBff {
  const maxAge = valor ? dias * DIA : 0;
  return {
    nombre: COOKIE_RENOVACION,
    valor,
    httpOnly: true,
    sameSite: 'strict',
    secure: seguro(),
    path: '/api/sesion',
    maxAge,
  };
}

/** Id que este navegador usa como dispositivo; dura un año y no identifica a la persona. */
export function cookieDispositivo(valor: string): CookieBff {
  return {
    nombre: COOKIE_DISPOSITIVO,
    valor,
    httpOnly: true,
    sameSite: 'lax',
    secure: seguro(),
    path: '/',
    maxAge: 365 * DIA,
  };
}

/** "Chrome en Windows": así la propietaria reconoce el computador en su lista de dispositivos. */
export function nombreDelNavegador(agente: string | null): string {
  const texto = agente ?? '';
  const navegador =
    [
      ['Edg/', 'Edge'],
      ['OPR/', 'Opera'],
      ['Firefox/', 'Firefox'],
      ['Chrome/', 'Chrome'],
      ['Safari/', 'Safari'],
    ].find(([marca]) => texto.includes(marca))?.[1] ?? 'Navegador';
  const sistema =
    [
      ['Windows', 'Windows'],
      ['Android', 'Android'],
      ['iPhone', 'iPhone'],
      ['Mac OS', 'Mac'],
      ['Linux', 'Linux'],
    ].find(([marca]) => texto.includes(marca))?.[1] ?? null;
  return sistema ? `${navegador} en ${sistema}` : navegador;
}
