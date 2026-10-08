import { PinTemporalNoPermitido } from '../errors/pin-temporal-no-permitido.error';

/**
 * A qué más da acceso una cuenta. Un PIN temporal entrega la cuenta entera a quien
 * lo recibe: no puede salir de un negocio si abre puertas de otro ni de VECI.
 */
export interface AlcanceDeCuenta {
  /** Negocios distintos del que pide el PIN donde la persona trabaja o está invitada. */
  readonly otrosNegociosComoPersonal: number;
  /** Tiene un rol vigente del equipo VECI (Administración o Soporte). */
  readonly esEquipoVeci: boolean;
}

/**
 * Un negocio (propietario o cajero) solo entrega PIN temporales de cuentas que no van
 * más allá de él; Soporte VECI no restablece cuentas del propio equipo VECI.
 */
export function asegurarPinTemporalPermitido(
  alcance: AlcanceDeCuenta,
  desdeComercio: boolean,
): void {
  if (alcance.esEquipoVeci) {
    throw new PinTemporalNoPermitido(
      'Esta cuenta es del equipo VECI: su PIN solo lo restablece Administración VECI.',
    );
  }
  if (desdeComercio && alcance.otrosNegociosComoPersonal > 0) {
    throw new PinTemporalNoPermitido(
      'Esta persona también trabaja en otro negocio con VECI. Para cuidar su cuenta, ' +
        'su PIN lo restablece Soporte VECI después de verificar su documento.',
    );
  }
}
