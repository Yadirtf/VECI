import { ErrorDeDominio } from './error-de-dominio';

/** Por qué una sesión ya no sirve. La app decide qué mostrar según el código. */
export type MotivoSesionNoValida = 'TOKEN_VENCIDO' | 'SESION_VENCIDA' | 'SESION_CERRADA';

const MENSAJES: Record<MotivoSesionNoValida, string> = {
  TOKEN_VENCIDO: 'Tu acceso se venció. Renueva la sesión, veci.',
  SESION_VENCIDA: 'Hace rato no entrabas. Vuelve a iniciar sesión, veci.',
  SESION_CERRADA: 'Tu sesión se cerró en este dispositivo. Vuelve a entrar con tu PIN.',
};

/** El token o la sesión ya no son válidos (HU-02-01, HU-02-06). */
export class SesionNoValida extends ErrorDeDominio {
  readonly tipo = 'no-autenticado' as const;

  constructor(readonly codigo: MotivoSesionNoValida) {
    super(MENSAJES[codigo]);
  }
}
