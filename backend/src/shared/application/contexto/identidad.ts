/**
 * Quién hace la petición (HU-02-01). La sesión y el dispositivo vienen del token;
 * la identidad de desarrollo (pruebas locales) no los tiene.
 */
export interface Identidad {
  readonly usuarioId: string;
  readonly sesionId: string | null;
  readonly dispositivoId: string | null;
}
