import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { Celular, EmitirPinTemporal } from '../../../autenticacion';
import { CelularEnUso, FaltanDatosDeRegistro } from '../../domain/errors/errores-clientes';
import {
  Actor,
  RegistroAsistidoInput,
  RegistroAsistidoOutput,
  RevisionDeDocumento,
} from '../dto/clientes.dto';
import { ClientesRepository, PersonaAsistida } from '../puertos/clientes.repository';
import { PoliticaRepository } from '../puertos/politica.repository';
import { TokensQr } from '../servicios/tokens-qr';
import { auditarAfiliacion } from './afiliar-por-qr.use-case';
import { asegurarPoliticaVigente } from './consultar-politica.use-case';
import { fichaDe } from './leer-qr.use-case';

export interface DependenciasRegistroAsistido {
  clientes: ClientesRepository;
  politicas: PoliticaRepository;
  tokens: TokensQr;
  pinTemporal: EmitirPinTemporal;
  auditoria: Auditoria;
}

/** Primer paso del registro en la caja: ¿esta persona ya está en VECI? (HU-04-04). */
export class RevisarDocumento {
  constructor(private readonly clientes: ClientesRepository) {}

  async ejecutar(tipo: string, numero: string): Promise<RevisionDeDocumento> {
    const persona = await this.clientes.personaPorDocumento(tipo, numero);
    if (!persona) return { persona: null };
    const { personaId, nombre, documento, clienteId } = persona;
    return { persona: { personaId, nombre, documento, clienteId } };
  }
}

/**
 * Registro asistido de quien no tiene la app (HU-04-04). Si el documento ya está en
 * VECI se afilia a esa persona sin duplicarla. Si es nueva, queda con un usuario
 * pendiente y un PIN de bienvenida para activar después su app con su celular.
 */
export class RegistrarAsistido {
  constructor(private readonly d: DependenciasRegistroAsistido) {}

  async ejecutar(actor: Actor, entrada: RegistroAsistidoInput): Promise<RegistroAsistidoOutput> {
    await asegurarPoliticaVigente(this.d.politicas, entrada.politicaVersionId);
    const existente = await this.d.clientes.personaPorDocumento(
      entrada.tipoDocumento,
      entrada.numeroDocumento,
    );
    const hecha = await this.d.clientes.afiliar({
      personaId: existente?.personaId ?? null,
      personaNueva: existente ? null : await this.personaNueva(entrada),
      canal: 'ASSISTED_REGISTRATION',
      actorUsuarioId: actor.usuarioId,
      clave: this.d.tokens.claveDelComercio(actor.comercioId),
      politicaVersionId: entrada.politicaVersionId,
    });
    await auditarAfiliacion(this.d.auditoria, actor, hecha, 'ASSISTED_REGISTRATION');
    const pinBienvenida = hecha.usuarioCreado
      ? await this.d.pinTemporal.ejecutar({
          usuarioId: hecha.usuarioCreado,
          motivo: 'INVITACION',
          porUsuarioId: actor.usuarioId,
          comercioId: actor.comercioId,
        })
      : null;
    const cliente = await fichaDe(this.d.clientes, hecha.clienteId);
    return { vinculado: existente !== null, cliente, pinBienvenida };
  }

  private async personaNueva(entrada: RegistroAsistidoInput): Promise<PersonaAsistida> {
    const nombres = entrada.nombres?.trim();
    if (!nombres || !entrada.celular) throw new FaltanDatosDeRegistro();
    const celular = Celular.de(entrada.celular).valor;
    const cuenta = await this.d.clientes.cuentaPorCelular(celular);
    if (cuenta && !entrada.celularCompartido) throw new CelularEnUso();
    return {
      nombres,
      apellidos: entrada.apellidos?.trim() || null,
      tipoDocumento: entrada.tipoDocumento,
      numeroDocumento: entrada.numeroDocumento,
      celular,
      conCuenta: cuenta === null,
    };
  }
}
