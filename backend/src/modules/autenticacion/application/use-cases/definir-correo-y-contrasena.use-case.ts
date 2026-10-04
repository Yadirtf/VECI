import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { GeneradorSecretos } from '../../../../shared/application/puertos/generador-secretos.port';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { CredencialesIncorrectas } from '../../domain/errors/credenciales-incorrectas.error';
import { Contrasena } from '../../domain/value-objects/contrasena.vo';
import { Correo } from '../../domain/value-objects/correo.vo';
import { CredencialesRepository } from '../puertos/credenciales.repository';
import { CuentasRepository } from '../puertos/cuentas.repository';
import { ComprobadorCredencial } from '../servicios/comprobador-credencial';

export interface DependenciasCorreo {
  cuentas: CuentasRepository;
  credenciales: CredencialesRepository;
  comprobador: ComprobadorCredencial;
  cifrador: CifradorSecretos;
  secretos: GeneradorSecretos;
}

export interface CorreoYContrasenaInput {
  identidad: Identidad;
  correo: string;
  contrasena: string;
  pinActual: string;
}

/**
 * Para entrar al panel desde el computador del negocio con correo y contraseña
 * (HU-02-02). Se confirma con el PIN: quien tomó un celular desbloqueado no
 * puede crear otra puerta de entrada.
 */
export class DefinirCorreoYContrasena {
  constructor(private readonly d: DependenciasCorreo) {}

  async ejecutar(entrada: CorreoYContrasenaInput): Promise<{ correo: string }> {
    const correo = Correo.de(entrada.correo);
    const contrasena = Contrasena.nueva(entrada.contrasena);
    const { usuarioId, dispositivoId } = entrada.identidad;
    const pin = await this.d.credenciales.vigente(usuarioId, 'PIN');
    if (!pin) throw new CredencialesIncorrectas('Primero crea tu PIN, veci.');
    await this.d.comprobador.comprobar(
      pin,
      entrada.pinActual,
      {
        huellaIdentificador: this.d.secretos.huella(usuarioId),
        usuarioId,
        dispositivoId,
        ip: null,
      },
      'El PIN no coincide, veci.',
    );
    await this.d.cuentas.asignarCorreo(usuarioId, correo.valor);
    await this.d.credenciales.reemplazar({
      usuarioId,
      tipo: 'PASSWORD',
      hash: await this.d.cifrador.cifrar(contrasena.valor),
      debeCambiar: false,
      motivo: 'CHANGED_BY_USER',
      creadaPor: usuarioId,
    });
    return { correo: correo.valor };
  }
}
