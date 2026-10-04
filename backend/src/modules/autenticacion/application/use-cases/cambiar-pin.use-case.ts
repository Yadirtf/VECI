import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import { GeneradorSecretos } from '../../../../shared/application/puertos/generador-secretos.port';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { CredencialesIncorrectas } from '../../domain/errors/credenciales-incorrectas.error';
import { Pin } from '../../domain/value-objects/pin.vo';
import { CredencialesRepository } from '../puertos/credenciales.repository';
import { ComprobadorCredencial } from '../servicios/comprobador-credencial';

export interface DependenciasCambiarPin {
  credenciales: CredencialesRepository;
  comprobador: ComprobadorCredencial;
  cifrador: CifradorSecretos;
  secretos: GeneradorSecretos;
}

export interface CambiarPinInput {
  identidad: Identidad;
  pinActual: string;
  pinNuevo: string;
}

/** La persona cambia su PIN desde "Mi cuenta"; el actual cuenta como intento. */
export class CambiarPin {
  constructor(private readonly d: DependenciasCambiarPin) {}

  async ejecutar({ identidad, pinActual, pinNuevo }: CambiarPinInput): Promise<void> {
    const pin = Pin.nuevo(pinNuevo);
    const credencial = await this.d.credenciales.vigente(identidad.usuarioId, 'PIN');
    if (!credencial) throw new CredencialesIncorrectas('Aún no tienes PIN, veci.');
    await this.d.comprobador.comprobar(
      credencial,
      pinActual,
      {
        huellaIdentificador: this.d.secretos.huella(identidad.usuarioId),
        usuarioId: identidad.usuarioId,
        dispositivoId: identidad.dispositivoId,
        ip: null,
      },
      'El PIN actual no coincide, veci.',
    );
    await this.d.credenciales.reemplazar({
      usuarioId: identidad.usuarioId,
      tipo: 'PIN',
      hash: await this.d.cifrador.cifrar(pin.valor),
      debeCambiar: false,
      motivo: 'CHANGED_BY_USER',
      creadaPor: identidad.usuarioId,
    });
  }
}
