import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { QrNoSirve } from '../../domain/errors/errores-clientes';
import { Actor, AfiliacionOutput } from '../dto/clientes.dto';
import { AfiliacionHecha, ClientesRepository } from '../puertos/clientes.repository';
import { LectorQr } from '../servicios/lector-qr';
import { TokensQr } from '../servicios/tokens-qr';
import { fichaDe } from './leer-qr.use-case';

export interface DependenciasAfiliar {
  clientes: ClientesRepository;
  lector: LectorQr;
  tokens: TokensQr;
  auditoria: Auditoria;
}

const MENSAJES: Record<string, string> = {
  QR_CAMBIADO: 'Este QR ya no sirve: fue cambiado. Pídele que abra Mi QR en su app.',
  OTRO_NEGOCIO: 'Este QR es de otro negocio. Pídele su QR personal de VECI.',
  NO_ES_DE_VECI: 'Este QR no es de VECI.',
};

/** Registra en la bitácora que el comercio sumó un cliente (audit.actions CUSTOMER_AFFILIATED). */
export async function auditarAfiliacion(
  auditoria: Auditoria,
  actor: Actor,
  hecha: AfiliacionHecha,
  canal: string,
): Promise<void> {
  if (!hecha.nueva) return;
  await auditoria.registrar({
    accion: 'CUSTOMER_AFFILIATED',
    tabla: 'customers.affiliations',
    entidadId: hecha.clienteId,
    actorUsuarioId: actor.usuarioId,
    comercioId: actor.comercioId,
    despues: { canal, personaId: hecha.personaId },
  });
}

/**
 * El cajero confirma y la persona queda afiliada con su QR único en este negocio
 * (HU-04-03). Si ya era cliente no se duplica: se abre su ficha.
 */
export class AfiliarPorQr {
  constructor(private readonly d: DependenciasAfiliar) {}

  async ejecutar(actor: Actor, texto: string): Promise<AfiliacionOutput> {
    const leido = await this.d.lector.leer(actor.comercioId, texto);
    if (leido.tipo === 'CLIENTE') {
      return { yaEstaba: true, cliente: await fichaDe(this.d.clientes, leido.clienteId) };
    }
    if (leido.tipo !== 'PERSONAL') throw new QrNoSirve(MENSAJES[leido.tipo]);
    const hecha = await this.d.clientes.afiliar({
      personaId: leido.previa.personaId,
      personaNueva: null,
      canal: 'PERSONAL_QR_SCAN',
      actorUsuarioId: actor.usuarioId,
      clave: this.d.tokens.claveDelComercio(actor.comercioId),
      politicaVersionId: null,
    });
    await auditarAfiliacion(this.d.auditoria, actor, hecha, 'PERSONAL_QR_SCAN');
    return { yaEstaba: !hecha.nueva, cliente: await fichaDe(this.d.clientes, hecha.clienteId) };
  }
}
