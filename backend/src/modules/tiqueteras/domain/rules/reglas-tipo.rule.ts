import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { DatosDeTipo } from '../entities/tipo-de-tiquetera';

/** Límites de un tipo de tiquetera: amplios para cualquier negocio, cerrados contra errores. */
export const LIMITES_TIPO = {
  nombre: { min: 3, max: 60 },
  unidades: { min: 1, max: 500 },
  precio: { min: 1_000, max: 20_000_000 },
  vigenciaDias: { min: 1, max: 365 },
} as const;

function entero(valor: number, campo: keyof typeof LIMITES_TIPO, mensaje: string): number {
  const { min, max } = LIMITES_TIPO[campo];
  if (!Number.isInteger(valor) || valor < min || valor > max) throw new DatoInvalido(mensaje);
  return valor;
}

/**
 * Revisa y limpia lo que escribió el propietario (HU-05-01): nombre, unidad, cuántas
 * unidades, precio en pesos sin centavos y cuántos días sirve.
 */
export function validarTipo(datos: DatosDeTipo): DatosDeTipo {
  const nombre = datos.nombre.trim().replace(/\s+/g, ' ');
  const { min, max } = LIMITES_TIPO.nombre;
  if (nombre.length < min || nombre.length > max) {
    throw new DatoInvalido(`El nombre debe tener entre ${min} y ${max} letras.`);
  }
  return {
    nombre,
    unidad: CodigoCatalogo.de(datos.unidad).valor,
    unidades: entero(datos.unidades, 'unidades', 'Las unidades van de 1 a 500.'),
    precio: entero(datos.precio, 'precio', 'El precio va de $1.000 a $20.000.000, sin centavos.'),
    vigenciaDias: entero(datos.vigenciaDias, 'vigenciaDias', 'La vigencia va de 1 a 365 días.'),
  };
}

/** Cuánto sale cada unidad, redondeado al peso: ayuda a comparar paquetes. */
export function precioPorUnidad(precio: number, unidades: number): number {
  return Math.round(precio / unidades);
}
