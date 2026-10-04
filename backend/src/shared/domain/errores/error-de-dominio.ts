/**
 * Error de una regla del negocio. La presentación lo traduce a una respuesta HTTP
 * con un código estable y un mensaje en tono VECI; el dominio no conoce HTTP.
 */
export abstract class ErrorDeDominio extends Error {
  abstract readonly codigo: string;
  abstract readonly tipo: TipoDeError;

  protected constructor(mensaje: string) {
    super(mensaje);
    this.name = new.target.name;
  }
}

/** Clasificación que la presentación usa para elegir el código HTTP. */
export type TipoDeError =
  'no-encontrado' | 'conflicto' | 'regla-incumplida' | 'no-autenticado' | 'prohibido';
