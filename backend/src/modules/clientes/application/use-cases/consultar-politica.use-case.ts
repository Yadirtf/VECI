import { PoliticaDesactualizada } from '../../domain/errors/errores-clientes';
import { PoliticaRepository, PoliticaVigente } from '../puertos/politica.repository';

/** La política de datos vigente para leerla antes de aceptar (HU-12-01, RF-CLI-05). */
export class ConsultarPolitica {
  constructor(private readonly politicas: PoliticaRepository) {}

  ejecutar(): Promise<PoliticaVigente> {
    return this.politicas.vigente();
  }
}

/**
 * Lo que se acepta es lo que se leyó: si la versión cambió entre que la persona la
 * leyó y que confirmó, se le pide leerla otra vez.
 */
export async function asegurarPoliticaVigente(
  politicas: PoliticaRepository,
  politicaVersionId: string,
): Promise<void> {
  const vigente = await politicas.vigente();
  if (vigente.id !== politicaVersionId) throw new PoliticaDesactualizada();
}
