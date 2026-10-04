import { DispositivoDelNegocio, DispositivosRepository } from '../puertos/dispositivos.repository';

/** Celulares de la caja con quién tiene sesión abierta en cada uno (HU-02-06). */
export class ListarDispositivos {
  constructor(private readonly dispositivos: DispositivosRepository) {}

  ejecutar(): Promise<DispositivoDelNegocio[]> {
    return this.dispositivos.listar();
  }
}
