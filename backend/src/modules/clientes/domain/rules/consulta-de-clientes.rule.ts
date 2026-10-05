import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { plegar } from './enmascarar.rule';

/** Lo que el cajero escribió en la búsqueda (HU-04-05). */
export type ConsultaDeClientes =
  | { readonly tipo: 'NOMBRE'; readonly palabras: readonly string[] }
  | { readonly tipo: 'NUMERO'; readonly digitos: string };

/** Desde 3 caracteres: antes, la lista no ayuda y cuesta en hora pico. */
export const MINIMO_PARA_BUSCAR = 3;

/**
 * Solo números (con espacios o guiones) → documento o celular; si no, nombre.
 * "310 000" busca celulares y documentos que contengan 310000.
 */
export function leerConsulta(texto: string): ConsultaDeClientes {
  const limpio = plegar(texto);
  const digitos = limpio.replace(/[\s\-+().]/g, '');
  if (/^\d+$/.test(digitos)) {
    if (digitos.length < MINIMO_PARA_BUSCAR) throw muyCorta();
    return { tipo: 'NUMERO', digitos };
  }
  const palabras = limpio
    .replace(/[^a-z0-9ñ ]/g, '')
    .split(' ')
    .filter(Boolean);
  if (palabras.join('').length < MINIMO_PARA_BUSCAR) throw muyCorta();
  return { tipo: 'NOMBRE', palabras };
}

function muyCorta(): DatoInvalido {
  return new DatoInvalido(`Escribe al menos ${MINIMO_PARA_BUSCAR} letras o números, veci.`);
}
