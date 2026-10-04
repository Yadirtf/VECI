import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { esPinFacilDeAdivinar } from '../rules/pin-facil-de-adivinar.rule';

const SEIS_DIGITOS = /^\d{6}$/;

/** PIN nuevo de 6 dígitos que la persona elige (HU-02-01, HU-02-05). */
export class Pin {
  private constructor(readonly valor: string) {}

  static nuevo(texto: string): Pin {
    if (!SEIS_DIGITOS.test(texto)) {
      throw new DatoInvalido('El PIN son 6 números, veci.');
    }
    if (esPinFacilDeAdivinar(texto)) {
      throw new DatoInvalido('Ese PIN es muy fácil de adivinar. Prueba con otros 6 números.');
    }
    return new Pin(texto);
  }
}
