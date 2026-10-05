import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { ComercioDelClienteOutput, MiQrOutput } from '../dto/clientes.dto';
import {
  MiQrRepository,
  QrDeAfiliacionGuardado,
  QrPersonalGuardado,
} from '../puertos/mi-qr.repository';
import { TokensQr } from '../servicios/tokens-qr';

/**
 * El QR personal en la app del cliente (HU-04-02): solo un token firmado, sin datos.
 * La app lo guarda y lo muestra sin internet. Si lo perdió o lo compartió, lo
 * regenera y el anterior deja de servir para afiliarse.
 */
export class MiQr {
  constructor(
    private readonly repo: MiQrRepository,
    private readonly tokens: TokensQr,
    private readonly auditoria: Auditoria,
  ) {}

  async consultar(usuarioId: string): Promise<MiQrOutput> {
    const personaId = await this.repo.personaDe(usuarioId);
    const qr = (await this.repo.vigente(personaId)) ?? (await this.repo.emitirPrimero(personaId));
    return this.salida(qr);
  }

  async regenerar(usuarioId: string): Promise<MiQrOutput> {
    const personaId = await this.repo.personaDe(usuarioId);
    const anterior = await this.repo.vigente(personaId);
    const nuevo = await this.repo.regenerar(personaId);
    await this.auditoria.registrar({
      accion: 'QR_REVOKED',
      tabla: 'customers.personal_qr_codes',
      entidadId: anterior?.qrId ?? null,
      actorUsuarioId: usuarioId,
      comercioId: null,
      despues: { motivo: 'REGENERATED', versionNueva: nuevo.version },
    });
    return this.salida(nuevo);
  }

  /**
   * Negocios donde es cliente, cada uno con el QR que ese negocio firmó (HU-04-03).
   * Si una afiliación aún no tiene QR vigente, se emite aquí mismo.
   */
  async comercios(usuarioId: string): Promise<ComercioDelClienteOutput[]> {
    const personaId = await this.repo.personaDe(usuarioId);
    const comercios = await this.repo.comercios(usuarioId, personaId);
    return Promise.all(
      comercios.map(async ({ qr, clienteId, ...comercio }) => {
        const en = { comercioId: comercio.comercioId, usuarioId };
        const vigente = qr ?? (await this.emitirQr(en, clienteId));
        const token = this.tokens.afiliacion(comercio.comercioId, clienteId, vigente);
        return { ...comercio, qr: { token, version: vigente.version } };
      }),
    );
  }

  private emitirQr(
    en: { comercioId: string; usuarioId: string },
    clienteId: string,
  ): Promise<QrDeAfiliacionGuardado> {
    const clave = this.tokens.claveDelComercio(en.comercioId);
    return this.repo.emitirQrDeAfiliacion(en, clienteId, clave);
  }

  private salida(qr: QrPersonalGuardado): MiQrOutput {
    return { token: this.tokens.personal(qr), version: qr.version, emitidoEn: qr.emitidoEn };
  }
}
