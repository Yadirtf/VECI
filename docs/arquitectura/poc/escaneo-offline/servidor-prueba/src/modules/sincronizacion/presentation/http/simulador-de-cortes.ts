import { Response } from 'express';

/**
 * Simula que la señal se cae justo después de que el servidor guardó el lote:
 * el celular no recibe la respuesta y reintenta. Es el caso que más duplicados causa.
 */
export class SimuladorDeCortes {
  constructor(private readonly random: () => number = Math.random) {}

  /** Devuelve true si cortó la conexión. */
  maybeCut(rate: number, res: Response): boolean {
    if (!(rate > 0) || this.random() >= rate) return false;
    res.socket?.destroy();
    return true;
  }
}

export function parseRate(raw: string | undefined): number {
  const rate = Number(raw ?? 0);
  return Number.isFinite(rate) ? Math.min(Math.max(rate, 0), 1) : 0;
}
