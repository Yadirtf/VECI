import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

const FORMATO_HORA = /^([01]\d|2[0-3]):([0-5]\d)$/;

function aMinutos(hora: string): number {
  const partes = FORMATO_HORA.exec(hora);
  if (!partes) {
    throw new DatoInvalido(`"${hora}" no es una hora válida (use HH:MM, de 00:00 a 23:59)`);
  }
  return Number(partes[1]) * 60 + Number(partes[2]);
}

/**
 * Horas de un horario de servicio, de inicio incluido a fin excluido: [11:30, 15:00).
 * Así un horario que termina a las 15:00 no se cruza con otro que empieza a las 15:00.
 */
export class RangoHoras {
  private constructor(
    readonly inicio: string,
    readonly fin: string,
    private readonly desde: number,
    private readonly hasta: number,
  ) {}

  static de(inicio: string, fin: string): RangoHoras {
    const desde = aMinutos(inicio);
    const hasta = aMinutos(fin);
    if (desde >= hasta) {
      throw new DatoInvalido('La hora de inicio debe ser antes de la hora de fin');
    }
    return new RangoHoras(inicio, fin, desde, hasta);
  }

  seCruzaCon(otro: RangoHoras): boolean {
    return this.desde < otro.hasta && otro.desde < this.hasta;
  }
}
