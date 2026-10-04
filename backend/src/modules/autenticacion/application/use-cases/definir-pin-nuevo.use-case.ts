import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { FirmadorTokens } from '../../../../shared/application/puertos/firmador-tokens.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import { CambioDePinNoValido } from '../../domain/errors/cambio-de-pin-no-valido.error';
import { CuentaNoHabilitada } from '../../domain/errors/cuenta-no-habilitada.error';
import { Pin } from '../../domain/value-objects/pin.vo';
import { SesionOutput } from '../dto/sesion.output';
import { CredencialesRepository } from '../puertos/credenciales.repository';
import { CuentasRepository } from '../puertos/cuentas.repository';
import { TOKEN_CAMBIO_DE_PIN } from '../puertos/reglas-sesion';
import { Dispositivo } from '../puertos/sesiones.repository';
import { EmisorSesion } from '../servicios/emisor-sesion';

export interface DependenciasDefinirPin {
  cuentas: CuentasRepository;
  credenciales: CredencialesRepository;
  cifrador: CifradorSecretos;
  firmador: FirmadorTokens;
  emisor: EmisorSesion;
}

export interface DefinirPinInput {
  tokenCambio: string;
  pinNuevo: string;
  dispositivo: Dispositivo;
}

/**
 * Después de entrar con un PIN temporal, la persona crea el suyo y recién ahí
 * abre sesión (HU-02-04, HU-02-05). El token sirve una vez: al reemplazar la
 * credencial, su id cambia y el token queda inválido.
 */
export class DefinirPinNuevo {
  constructor(private readonly d: DependenciasDefinirPin) {}

  async ejecutar(entrada: DefinirPinInput): Promise<SesionOutput> {
    const { usuarioId, credencialId } = this.leerToken(entrada);
    const pin = Pin.nuevo(entrada.pinNuevo);
    const credencial = await this.d.credenciales.vigente(usuarioId, 'PIN');
    const cuenta = await this.d.cuentas.buscarPorId(usuarioId);
    if (!credencial || credencial.id !== credencialId || !credencial.debeCambiar || !cuenta) {
      throw new CambioDePinNoValido();
    }
    if (!cuenta.puedeEntrar && !cuenta.pendienteDeActivar) throw new CuentaNoHabilitada();
    if (await this.d.cifrador.coincide(credencial.hash, pin.valor)) {
      throw new DatoInvalido('Elige un PIN distinto al temporal, veci.');
    }
    await this.d.credenciales.reemplazar({
      usuarioId,
      tipo: 'PIN',
      hash: await this.d.cifrador.cifrar(pin.valor),
      debeCambiar: false,
      motivo: 'CHANGED_BY_USER',
      creadaPor: usuarioId,
    });
    if (cuenta.pendienteDeActivar) await this.d.cuentas.activar(usuarioId);
    return this.d.emisor.abrir(
      { ...cuenta, puedeEntrar: true, pendienteDeActivar: false },
      entrada.dispositivo,
    );
  }

  private leerToken(entrada: DefinirPinInput): { usuarioId: string; credencialId: string } {
    const verificado = this.d.firmador.verificar(entrada.tokenCambio);
    if (verificado.estado !== 'valido') throw new CambioDePinNoValido();
    const { typ, sub, cred, dev } = verificado.carga;
    const valido =
      typ === TOKEN_CAMBIO_DE_PIN && typeof sub === 'string' && typeof cred === 'string';
    if (!valido || dev !== entrada.dispositivo.id) throw new CambioDePinNoValido();
    return { usuarioId: sub, credencialId: cred };
  }
}
