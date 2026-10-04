import { Miembro } from '../../domain/entities/miembro';
import { PersonalRepository } from '../puertos/personal.repository';

/** Equipo del negocio con su estado, sin los retirados (HU-02-04). */
export class ListarPersonal {
  constructor(private readonly personal: PersonalRepository) {}

  async ejecutar(): Promise<Miembro[]> {
    return (await this.personal.listar()).filter((miembro) => miembro.estado !== 'REMOVED');
  }
}
