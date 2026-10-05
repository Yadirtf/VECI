import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { RangoHoras } from '../value-objects/rango-horas.vo';

export interface DatosHorarioServicio {
  id: string;
  servicioId: string;
  sedeId: string;
  dia: CodigoCatalogo;
  horas: RangoHoras;
  /** En pausa (false): no cuenta para el antifraude ni se cruza con otros. */
  activo?: boolean;
}

/**
 * Horario de servicio de una sede (desayuno de 6:30 a 9:30 los lunes, por ejemplo).
 * En un colegio el mismo modelo sirve para el recreo (RNF-ESC-02).
 */
export class HorarioServicio {
  private constructor(private readonly datos: DatosHorarioServicio) {}

  static crear(datos: DatosHorarioServicio): HorarioServicio {
    return new HorarioServicio({ ...datos, activo: datos.activo ?? true });
  }

  get id(): string {
    return this.datos.id;
  }

  get servicioId(): string {
    return this.datos.servicioId;
  }

  get sedeId(): string {
    return this.datos.sedeId;
  }

  get dia(): CodigoCatalogo {
    return this.datos.dia;
  }

  get horas(): RangoHoras {
    return this.datos.horas;
  }

  get activo(): boolean {
    return this.datos.activo !== false;
  }

  /** Mismo horario con otras horas o en pausa. Al guardarse, recibe un id nuevo. */
  con(cambios: { id: string; horas?: RangoHoras; activo?: boolean }): HorarioServicio {
    return HorarioServicio.crear({ ...this.datos, ...cambios });
  }

  /** Dos horarios activos de la misma sede, el mismo día, con horas que se cruzan. */
  seCruzaCon(otro: HorarioServicio): boolean {
    return (
      this.id !== otro.id &&
      this.activo &&
      otro.activo &&
      this.sedeId === otro.sedeId &&
      this.dia.igualA(otro.dia) &&
      this.horas.seCruzaCon(otro.horas)
    );
  }
}
