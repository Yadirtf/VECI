import { CodigoCatalogo } from '../../../../shared/domain/codigo-catalogo.vo';
import { RangoHoras } from '../value-objects/rango-horas.vo';

export interface DatosHorarioServicio {
  id: string;
  servicioId: string;
  sedeId: string;
  dia: CodigoCatalogo;
  horas: RangoHoras;
}

/**
 * Horario de servicio de una sede (desayuno de 6:30 a 9:30 los lunes, por ejemplo).
 * En un colegio el mismo modelo sirve para el recreo (RNF-ESC-02).
 */
export class HorarioServicio {
  private constructor(private readonly datos: DatosHorarioServicio) {}

  static crear(datos: DatosHorarioServicio): HorarioServicio {
    return new HorarioServicio({ ...datos });
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

  /** Mismo día, misma sede y horas que se cruzan. */
  seCruzaCon(otro: HorarioServicio): boolean {
    return (
      this.sedeId === otro.sedeId && this.dia.igualA(otro.dia) && this.horas.seCruzaCon(otro.horas)
    );
  }
}
