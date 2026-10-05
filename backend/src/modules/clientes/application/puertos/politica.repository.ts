/** Una sección del texto legal con su explicación corta (HU-12-01). */
export interface SeccionPolitica {
  titulo: string;
  enPalabrasDeVecino: string;
  texto: string;
}

/** Texto de una versión de la política de tratamiento de datos. */
export interface ContenidoPolitica {
  version: string;
  /** Lo que se lee en voz alta en la caja o se ve en la app antes de aceptar. */
  enCorto: { anotamos: string[]; nuncaHacemos: string[]; paraQue: string };
  secciones: SeccionPolitica[];
}

/** Versión publicada (compliance.policy_versions) con su contenido. */
export interface PoliticaVigente extends ContenidoPolitica {
  id: string;
  publicadaEn: Date;
  /** SHA-256 del contenido guardado en la base, en hexadecimal. */
  huella: string;
}

export interface PoliticaRepository {
  /** La última versión publicada de la política de datos. */
  vigente(): Promise<PoliticaVigente>;
}

export const POLITICA_REPOSITORY = Symbol('PoliticaRepository');
