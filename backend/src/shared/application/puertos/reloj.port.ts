/** La hora actual. Las pruebas la fijan para comprobar bloqueos y vencimientos. */
export interface Reloj {
  ahora(): Date;
}

export const RELOJ = Symbol('Reloj');
