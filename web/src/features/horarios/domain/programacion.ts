import { DIAS } from './agrupar-por-dia';
import { aHora, aMinutos } from './arco';
import { primerHueco } from './dia-de-servicio';
import type { Horario } from './horario';

export type Rango = { inicio: number; fin: number };

/** Atajos para elegir varios días de un toque. */
export const ATAJOS: ReadonlyArray<{ nombre: string; dias: string[] }> = [
  { nombre: 'Lunes a viernes', dias: DIAS.slice(0, 5).map(([d]) => d) },
  { nombre: 'Lunes a sábado', dias: DIAS.slice(0, 6).map(([d]) => d) },
  { nombre: 'Toda la semana', dias: DIAS.map(([d]) => d) },
  { nombre: 'Fin de semana', dias: ['SATURDAY', 'SUNDAY'] },
];

export type Accion = 'crear' | 'cambiar' | 'igual';

export interface DiaDelPlan {
  dia: string;
  nombre: string;
  accion: Accion;
  /** Otro servicio que ese día ocupa esas horas: hay que moverlo primero. */
  cruce: Horario | null;
}

/**
 * Lo que pasará al guardar un servicio con esas horas en esos días (HU-03-02): dónde se
 * crea, dónde se cambian las horas y dónde se cruza con otro servicio. Es la misma
 * regla que aplica el API, para avisar antes de tocar "Guardar".
 */
export function planDeProgramacion(
  deLaSede: readonly Horario[],
  servicioId: string | null,
  dias: readonly string[],
  rango: Rango,
): DiaDelPlan[] {
  return DIAS.filter(([dia]) => dias.includes(dia)).map(([dia, nombre]) => {
    const delDia = deLaSede.filter((h) => h.dia === dia);
    const propios = delDia.filter((h) => h.servicioId === servicioId);
    const igual =
      propios.length === 1 &&
      propios[0].activo &&
      propios[0].horaInicio === aHora(rango.inicio) &&
      propios[0].horaFin === aHora(rango.fin);
    const cruce =
      delDia.find(
        (h) =>
          h.servicioId !== servicioId &&
          h.activo &&
          aMinutos(h.horaInicio) < rango.fin &&
          rango.inicio < aMinutos(h.horaFin),
      ) ?? null;
    const accion: Accion = igual ? 'igual' : propios.length > 0 ? 'cambiar' : 'crear';
    return { dia, nombre, accion, cruce: igual ? null : cruce };
  });
}

const HABITUALES: ReadonlyArray<[patron: RegExp, inicio: string, fin: string]> = [
  [/desayuno/i, '06:00', '09:00'],
  [/almuerzo/i, '11:30', '15:00'],
  [/(cena|comida)/i, '18:00', '21:00'],
];

const minutosDe = (h: Horario): Rango => ({
  inicio: aMinutos(h.horaInicio),
  fin: aMinutos(h.horaFin),
});

/**
 * Horas para empezar a programar un servicio: las que ya tiene (primero las del día
 * que se ve), las de costumbre para desayuno, almuerzo y cena, o el primer hueco libre.
 */
export function horasSugeridas(
  deLaSede: readonly Horario[],
  dia: string,
  servicio: { id: string | null; nombre: string },
): Rango {
  const propios = deLaSede.filter((h) => h.servicioId === servicio.id);
  const existente = propios.find((h) => h.dia === dia) ?? propios[0];
  if (existente) return minutosDe(existente);
  const habitual = HABITUALES.find(([patron]) => patron.test(servicio.nombre));
  if (habitual) return { inicio: aMinutos(habitual[1]), fin: aMinutos(habitual[2]) };
  return primerHueco(deLaSede.filter((h) => h.dia === dia)) ?? { inicio: 12 * 60, fin: 14 * 60 };
}
