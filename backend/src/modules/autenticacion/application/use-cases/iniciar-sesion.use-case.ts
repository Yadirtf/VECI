import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { FirmadorTokens } from '../../../../shared/application/puertos/firmador-tokens.port';
import { GeneradorSecretos } from '../../../../shared/application/puertos/generador-secretos.port';
import { TipoCredencial } from '../../domain/entities/credencial.entity';
import { Credencial } from '../../domain/entities/credencial.entity';
import { Cuenta } from '../../domain/entities/cuenta';
import { CredencialesIncorrectas } from '../../domain/errors/credenciales-incorrectas.error';
import { CuentaNoHabilitada } from '../../domain/errors/cuenta-no-habilitada.error';
import { Celular } from '../../domain/value-objects/celular.vo';
import { Correo } from '../../domain/value-objects/correo.vo';
import { IngresoInput } from '../dto/ingreso.input';
import { ResultadoIngreso } from '../dto/sesion.output';
import { CredencialesRepository } from '../puertos/credenciales.repository';
import { CuentasRepository, TipoIdentificador } from '../puertos/cuentas.repository';
import { IntentosIngreso } from '../puertos/intentos-ingreso.port';
import { SEGUNDOS_CAMBIO_DE_PIN, TOKEN_CAMBIO_DE_PIN } from '../puertos/reglas-sesion';
import { ComprobadorCredencial, DatosIntento } from '../servicios/comprobador-credencial';
import { EmisorSesion } from '../servicios/emisor-sesion';

/** Hash de un secreto que nadie conoce: iguala el tiempo de respuesta si el celular no existe. */
const HASH_SENUELO =
  '$argon2id$v=19$m=19456,t=2,p=1$0nUV7oD/Yc+1ee+VnWOCFA$xFIP5cVgVGBzv2RsvIMKHjZYYlqvEM9owqIQO0XT7tI';

export interface DependenciasIngreso {
  cuentas: CuentasRepository;
  credenciales: CredencialesRepository;
  intentos: IntentosIngreso;
  comprobador: ComprobadorCredencial;
  cifrador: CifradorSecretos;
  secretos: GeneradorSecretos;
  firmador: FirmadorTokens;
  emisor: EmisorSesion;
}

interface Via {
  tipoIdentificador: TipoIdentificador;
  valor: string;
  tipoCredencial: TipoCredencial;
  mensaje: string;
}

function leerVia(entrada: IngresoInput): Via {
  if (entrada.via === 'PIN') {
    const valor = Celular.de(entrada.identificador).valor;
    const mensaje = 'El celular o el PIN no coinciden, veci. Revisa e intenta otra vez.';
    return { tipoIdentificador: 'MOBILE_PHONE', valor, tipoCredencial: 'PIN', mensaje };
  }
  const valor = Correo.de(entrada.identificador).valor;
  const mensaje = 'El correo o la contraseña no coinciden, veci. Revisa e intenta otra vez.';
  return { tipoIdentificador: 'EMAIL', valor, tipoCredencial: 'PASSWORD', mensaje };
}

/** Un invitado sin activar puede entrar solo para crear su PIN. */
function estaHabilitada(cuenta: Cuenta, credencial: Credencial): boolean {
  return cuenta.puedeEntrar || (cuenta.pendienteDeActivar && credencial.debeCambiar);
}

/**
 * Inicio de sesión con celular + PIN o correo + contraseña (HU-02-01, HU-02-02).
 * Si el PIN es temporal (invitación o restablecimiento), no abre sesión: entrega
 * un token de 10 minutos para crear el PIN propio (HU-02-05).
 */
export class IniciarSesion {
  constructor(private readonly d: DependenciasIngreso) {}

  async ejecutar(entrada: IngresoInput): Promise<ResultadoIngreso> {
    const via = leerVia(entrada);
    const intento: DatosIntento = {
      huellaIdentificador: this.d.secretos.huella(via.valor),
      usuarioId: null,
      dispositivoId: entrada.dispositivo.id,
      ip: entrada.ip,
    };
    const cuenta = await this.d.cuentas.buscarPorIdentificador(via.tipoIdentificador, via.valor);
    const credencial = cuenta
      ? await this.d.credenciales.vigente(cuenta.usuarioId, via.tipoCredencial)
      : null;
    if (!cuenta || !credencial) {
      await this.d.cifrador.coincide(HASH_SENUELO, entrada.secreto);
      const motivoFallo = cuenta ? 'WRONG_SECRET' : 'UNKNOWN_IDENTIFIER';
      await this.d.intentos.registrar({
        ...intento,
        usuarioId: cuenta?.usuarioId ?? null,
        motivoFallo,
      });
      throw new CredencialesIncorrectas(via.mensaje);
    }
    return this.continuar(cuenta, credencial, entrada, { ...intento, usuarioId: cuenta.usuarioId });
  }

  private async continuar(
    cuenta: Cuenta,
    credencial: Credencial,
    entrada: IngresoInput,
    intento: DatosIntento,
  ): Promise<ResultadoIngreso> {
    await this.d.comprobador.comprobar(
      credencial,
      entrada.secreto,
      intento,
      leerVia(entrada).mensaje,
    );
    if (!estaHabilitada(cuenta, credencial)) {
      await this.d.intentos.registrar({ ...intento, motivoFallo: 'USER_NOT_ALLOWED' });
      throw new CuentaNoHabilitada();
    }
    await this.d.intentos.registrar({ ...intento, motivoFallo: null });
    if (credencial.debeCambiar) {
      const tokenCambio = this.d.firmador.firmar(
        {
          typ: TOKEN_CAMBIO_DE_PIN,
          sub: cuenta.usuarioId,
          cred: credencial.id,
          dev: entrada.dispositivo.id,
        },
        SEGUNDOS_CAMBIO_DE_PIN,
      );
      return { tipo: 'CAMBIO_DE_PIN', tokenCambio, nombre: cuenta.nombre };
    }
    return { tipo: 'SESION', sesion: await this.d.emisor.abrir(cuenta, entrada.dispositivo) };
  }
}
