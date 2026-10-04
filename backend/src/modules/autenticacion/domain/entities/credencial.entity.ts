/** Tipo de credencial (catálogo identity.credential_types). */
export type TipoCredencial = 'PIN' | 'PASSWORD';

/** Reglas de bloqueo que vienen del catálogo, no del código (ADR-0006). */
export interface ReglasBloqueo {
  maxIntentos: number;
  minutosBloqueo: number;
}

export interface DatosCredencial {
  id: string;
  usuarioId: string;
  tipo: TipoCredencial;
  hash: string;
  debeCambiar: boolean;
  intentosFallidos: number;
  bloqueadaHasta: Date | null;
  reglas: ReglasBloqueo;
}

/**
 * PIN o contraseña vigente de un usuario. Lleva la cuenta de intentos fallidos y
 * se bloquea un tiempo al llegar al máximo (HU-02-01: 5 intentos, 15 minutos).
 */
export class Credencial {
  private constructor(private datos: DatosCredencial) {}

  static desde(datos: DatosCredencial): Credencial {
    return new Credencial({ ...datos });
  }

  get id(): string {
    return this.datos.id;
  }

  get usuarioId(): string {
    return this.datos.usuarioId;
  }

  get tipo(): TipoCredencial {
    return this.datos.tipo;
  }

  get hash(): string {
    return this.datos.hash;
  }

  get debeCambiar(): boolean {
    return this.datos.debeCambiar;
  }

  get intentosFallidos(): number {
    return this.datos.intentosFallidos;
  }

  get bloqueadaHasta(): Date | null {
    return this.datos.bloqueadaHasta;
  }

  estaBloqueada(ahora: Date): boolean {
    return this.datos.bloqueadaHasta !== null && this.datos.bloqueadaHasta > ahora;
  }

  /** Minutos que faltan para poder intentar de nuevo (mínimo 1). */
  minutosRestantes(ahora: Date): number {
    const hasta = this.datos.bloqueadaHasta?.getTime() ?? ahora.getTime();
    return Math.max(1, Math.ceil((hasta - ahora.getTime()) / 60_000));
  }

  /** Suma un intento fallido. Devuelve true si con este intento quedó bloqueada. */
  registrarFallo(ahora: Date): boolean {
    const intentos = this.datos.intentosFallidos + 1;
    if (intentos < this.datos.reglas.maxIntentos) {
      this.datos = { ...this.datos, intentosFallidos: intentos };
      return false;
    }
    const hasta = new Date(ahora.getTime() + this.datos.reglas.minutosBloqueo * 60_000);
    this.datos = { ...this.datos, intentosFallidos: 0, bloqueadaHasta: hasta };
    return true;
  }

  registrarExito(): void {
    this.datos = { ...this.datos, intentosFallidos: 0, bloqueadaHasta: null };
  }
}
