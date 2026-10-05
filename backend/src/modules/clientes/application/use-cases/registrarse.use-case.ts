import { CifradorSecretos } from '../../../../shared/application/puertos/cifrador-secretos.port';
import {
  Celular,
  Dispositivo,
  EntrarConCuentaNueva,
  Pin,
  SesionOutput,
} from '../../../autenticacion';
import {
  DocumentoSinCuenta,
  YaTeAnotaron,
  YaTieneCuenta,
} from '../../domain/errors/errores-clientes';
import { PoliticaRepository } from '../puertos/politica.repository';
import { RegistroRepository, TipoDeDocumento } from '../puertos/registro.repository';
import { asegurarPoliticaVigente } from './consultar-politica.use-case';

export interface DependenciasRegistro {
  registro: RegistroRepository;
  politicas: PoliticaRepository;
  cifrador: CifradorSecretos;
  entrar: EntrarConCuentaNueva;
}

export interface RegistroInput {
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
  celular: string;
  pin: string;
  politicaVersionId: string;
  dispositivo: Dispositivo;
  ip: string | null;
}

/**
 * El cliente se registra solo en la app (HU-04-01): acepta la política, queda con su
 * QR personal y entra de una vez. Si su celular o documento ya están en VECI, le
 * decimos cómo entrar sin revelar en qué negocios está.
 */
export class Registrarse {
  constructor(private readonly d: DependenciasRegistro) {}

  /** Para elegir el documento en la app y validarlo antes de enviar. */
  tiposDeDocumento(): Promise<TipoDeDocumento[]> {
    return this.d.registro.tiposDeDocumento();
  }

  async ejecutar(entrada: RegistroInput): Promise<SesionOutput> {
    const celular = Celular.de(entrada.celular).valor;
    const pin = Pin.nuevo(entrada.pin).valor;
    await asegurarPoliticaVigente(this.d.politicas, entrada.politicaVersionId);
    await this.asegurarQueEsNuevo(celular, entrada.tipoDocumento, entrada.numeroDocumento);
    const { usuarioId } = await this.d.registro.registrar({
      nombres: entrada.nombres.trim(),
      apellidos: entrada.apellidos?.trim() || null,
      tipoDocumento: entrada.tipoDocumento,
      numeroDocumento: entrada.numeroDocumento,
      celular,
      hashPin: await this.d.cifrador.cifrar(pin),
      politicaVersionId: entrada.politicaVersionId,
      ip: entrada.ip,
    });
    return this.d.entrar.ejecutar(usuarioId, entrada.dispositivo);
  }

  private async asegurarQueEsNuevo(celular: string, tipo: string, numero: string): Promise<void> {
    const porCelular = await this.d.registro.cuentaPorCelular(celular);
    if (porCelular === 'ACTIVA') throw new YaTieneCuenta('celular');
    if (porCelular === 'PENDIENTE') throw new YaTeAnotaron();
    const porDocumento = await this.d.registro.cuentaPorDocumento(tipo, numero);
    if (porDocumento === 'ACTIVA') throw new YaTieneCuenta('documento');
    if (porDocumento === 'PENDIENTE') throw new YaTeAnotaron();
    if (porDocumento === 'SIN_CUENTA') throw new DocumentoSinCuenta();
  }
}
