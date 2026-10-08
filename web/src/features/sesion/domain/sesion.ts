/** Negocio donde la persona trabaja o es cliente, como lo devuelve la API. */
export interface Espacio {
  comercioId: string;
  nombre: string;
  tipoNegocio: string;
  roles: readonly string[];
  invitacionPendiente: boolean;
}

export interface Usuario {
  id: string;
  nombre: string;
}

/** Sesión abierta en el panel. El token de renovación nunca llega aquí: vive en una cookie httpOnly. */
export interface SesionActiva {
  tokenAcceso: string;
  /** Momento (ms desde 1970) en que vence el token de acceso. */
  venceEn: number;
  usuario: Usuario;
  espacios: readonly Espacio[];
}

export type ResultadoIngreso =
  | { tipo: 'sesion'; sesion: SesionActiva }
  | { tipo: 'cambio-de-pin'; tokenCambio: string; nombre: string };

/** Problema que la persona puede entender y resolver, con el texto en tono VECI. */
export class ErrorDeSesion extends Error {
  constructor(
    readonly codigo: string,
    mensaje: string,
  ) {
    super(mensaje);
  }
}

/** Cómo el panel abre, renueva y cierra sesiones; la infraestructura decide por dónde. */
export interface RepositorioSesion {
  entrarConPin(celular: string, pin: string): Promise<ResultadoIngreso>;
  entrarConContrasena(correo: string, contrasena: string): Promise<ResultadoIngreso>;
  crearPinNuevo(tokenCambio: string, pinNuevo: string): Promise<SesionActiva>;
  /** null si no hay sesión guardada o ya se cerró. */
  renovar(): Promise<SesionActiva | null>;
  elegirComercio(tokenAcceso: string, comercioId: string): Promise<void>;
  /** Qué puede hacer en la consola VECI; vacío si no es del equipo VECI. */
  permisosDePlataforma(tokenAcceso: string): Promise<string[]>;
  salir(tokenAcceso: string | null): Promise<void>;
}

/** Dónde se recuerda el negocio elegido entre recargas (no es un dato secreto). */
export interface PreferenciasSesion {
  comercioGuardado(): string | null;
  guardarComercio(comercioId: string | null): void;
}
