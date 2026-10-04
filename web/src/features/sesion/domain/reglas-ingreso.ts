import type { Espacio } from './sesion';

/** El panel es para quien administra el negocio; la caja trabaja en la app. */
export const ROLES_DEL_PANEL: readonly string[] = ['OWNER'];

export function negociosDelPanel(espacios: readonly Espacio[]): Espacio[] {
  return espacios.filter((e) => e.roles.some((rol) => ROLES_DEL_PANEL.includes(rol)));
}

/** Quita espacios, guiones y el +57 para revisar el celular antes de enviarlo. */
export function soloDigitosDelCelular(texto: string): string {
  const digitos = texto.replace(/\D/g, '');
  return digitos.length === 12 && digitos.startsWith('57') ? digitos.slice(2) : digitos;
}

/** Revisión amable antes de llamar a la API; la regla de verdad está en el servidor. */
export function problemaConCelular(texto: string): string | null {
  const digitos = soloDigitosDelCelular(texto);
  if (digitos.length === 0) return 'Escribe tu número de celular.';
  if (digitos.length !== 10 || !digitos.startsWith('3')) {
    return 'El celular son 10 números y empieza por 3, como 310 000 0101.';
  }
  return null;
}

export function problemaConPin(pin: string): string | null {
  return /^\d{6}$/.test(pin) ? null : 'El PIN son 6 números.';
}

/** Elige el negocio con el que arranca el panel: el guardado si sigue siendo válido, o el único. */
export function comercioInicial(
  negocios: readonly Espacio[],
  guardado: string | null,
): string | null {
  if (guardado && negocios.some((n) => n.comercioId === guardado)) return guardado;
  return negocios.length === 1 ? negocios[0].comercioId : null;
}
