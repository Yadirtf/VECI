import type { Horario } from './horario';

/** Nombres de los días en el orden de la semana colombiana (lunes primero). */
const DIAS: ReadonlyArray<[codigo: string, nombre: string]> = [
  ['MONDAY', 'Lunes'],
  ['TUESDAY', 'Martes'],
  ['WEDNESDAY', 'Miércoles'],
  ['THURSDAY', 'Jueves'],
  ['FRIDAY', 'Viernes'],
  ['SATURDAY', 'Sábado'],
  ['SUNDAY', 'Domingo'],
];

export interface DiaConHorarios {
  dia: string;
  nombre: string;
  horarios: Horario[];
}

/** Agrupa los horarios por día, en orden de semana y de hora; omite días sin servicio. */
export function agruparPorDia(horarios: readonly Horario[]): DiaConHorarios[] {
  return DIAS.map(([dia, nombre]) => ({
    dia,
    nombre,
    horarios: horarios
      .filter((h) => h.dia === dia)
      .sort((a, b) => a.horaInicio.localeCompare(b.horaInicio)),
  })).filter((grupo) => grupo.horarios.length > 0);
}

/** "11:30" → "11:30 a. m."; "15:00" → "3:00 p. m." */
export function horaLegible(hora: string): string {
  const [h, m] = hora.split(':').map(Number);
  const sufijo = h < 12 ? 'a. m.' : 'p. m.';
  const hora12 = h % 12 === 0 ? 12 : h % 12;
  return `${hora12}:${String(m).padStart(2, '0')} ${sufijo}`;
}
