import { Avance, PasoDelCamino } from '../entities/comercio';
import { NegocioSinHorarios } from '../errors/errores-comercios';

/**
 * Lo mínimo para abrir: los datos (ya existen al registrarse) y al menos un servicio
 * con horario, porque sin horario el control antifraude no sabe cuándo atiende.
 * Cajeros y tiqueteras ayudan, pero el dueño puede atender solo y vender después.
 */
export function caminoDeApertura(avance: Avance): PasoDelCamino[] {
  return [
    { codigo: 'DATOS', listo: true, obligatorio: true },
    { codigo: 'HORARIOS', listo: avance.serviciosConHorario > 0, obligatorio: true },
    { codigo: 'EQUIPO', listo: avance.cajeros > 0, obligatorio: false },
    { codigo: 'TIQUETERAS', listo: avance.tiqueteras > 0, obligatorio: false },
  ];
}

export function asegurarListoParaAbrir(avance: Avance): void {
  const falta = caminoDeApertura(avance).some((paso) => paso.obligatorio && !paso.listo);
  if (falta) throw new NegocioSinHorarios();
}
