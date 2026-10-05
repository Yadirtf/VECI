/** Tipo de credencial (catálogo identity.credential_types). */
export type TipoCredencial = 'PIN' | 'PASSWORD';

/** Reglas de bloqueo que vienen del catálogo, no del código (ADR-0006). */
export interface ReglasBloqueo {
  maxIntentos: number;
  minutosBloqueo: number;
  /** Horas que sirve una credencial temporal; null o ausente = no vence. */
  horasTemporal?: number | null;
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
  /** Cuándo se emitió: el PIN temporal vence contado desde aquí. */
  emitidaEn?: Date;
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

  /** PIN temporal (invitación o bienvenida) que nadie usó a tiempo (EP-04: 7 días). */
  temporalVencida(ahora: Date): boolean {
    const horas = this.datos.reglas.horasTemporal;
    if (!this.datos.debeCambiar || !horas || !this.datos.emitidaEn) return false;
    return ahora.getTime() - this.datos.emitidaEn.getTime() > horas * 3_600_000;
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
