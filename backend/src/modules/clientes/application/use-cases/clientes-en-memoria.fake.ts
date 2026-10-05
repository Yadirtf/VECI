import { EntradaAuditoria } from '../../../../shared/application/puertos/auditoria.port';
import { FirmadorQr, FirmanteQr } from '../../../../shared/application/puertos/firmador-qr.port';
import { EmitirPinTemporal } from '../../../autenticacion';
import { Cliente, EstadoCuenta } from '../../domain/entities/cliente';
import { ConsultaDeClientes } from '../../domain/rules/consulta-de-clientes.rule';
import { plegar } from '../../domain/rules/enmascarar.rule';
import {
  AfiliacionHecha,
  ClientesRepository,
  CopiaLocal,
  NuevaAfiliacion,
  PersonaEnVeci,
  VistaPreviaQrPersonal,
} from '../puertos/clientes.repository';
import { PoliticaRepository, PoliticaVigente } from '../puertos/politica.repository';
import { TokensQr } from '../servicios/tokens-qr';

/** Persona de la plataforma en memoria. */
export interface PersonaFalsa {
  personaId: string;
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
  celular: string;
  cuenta: EstadoCuenta;
  usuarioId: string | null;
}

/** Firma de mentira, determinista y distinta por firmante: suficiente para los casos de uso. */
export const firmadorFalso: FirmadorQr = {
  referenciaPrivada: 'prueba',
  firmar: (f: FirmanteQr, m: string) =>
    Buffer.from(`${f.comercioId}|${f.keyId}|${m}`).toString('base64url'),
  verificar: (f: FirmanteQr, m: string, firma: string) =>
    firma === Buffer.from(`${f.comercioId}|${f.keyId}|${m}`).toString('base64url'),
  clavePublica: () => new Uint8Array(32),
};

export const POLITICA: PoliticaVigente = {
  id: 'pol-1',
  version: '1.0',
  publicadaEn: new Date('2026-10-07T00:00:00Z'),
  huella: 'ab',
  enCorto: { anotamos: ['Tu nombre'], nuncaHacemos: ['Vender tus datos'], paraQue: 'Tu tiquetera' },
  secciones: [],
};

export const uuid = (n: number) => `00000000-0000-7000-8000-${String(n).padStart(12, '0')}`;

/** Un comercio con sus clientes y la plataforma con sus personas, sin base de datos. */
export class ClientesEnMemoria implements ClientesRepository, PoliticaRepository {
  readonly personas: PersonaFalsa[] = [];
  readonly afiliaciones: { clienteId: string; personaId: string; canal: string; en: Date }[] = [];
  readonly qrPersonales: { qrId: string; personaId: string; version: number; vigente: boolean }[] =
    [];
  readonly qrAfiliacion: { qrId: string; clienteId: string; version: number; vigente: boolean }[] =
    [];
  readonly consentimientos: { personaId: string; politicaVersionId: string }[] = [];
  readonly auditoria: EntradaAuditoria[] = [];
  readonly pines: unknown[] = [];
  readonly tokens = new TokensQr(firmadorFalso);
  private contador = 100;

  readonly bitacora = { registrar: async (e: EntradaAuditoria) => void this.auditoria.push(e) };
  readonly pinTemporal = {
    ejecutar: async (entrada: unknown) => {
      this.pines.push(entrada);
      return '730284';
    },
  } as unknown as EmitirPinTemporal;

  async vigente(): Promise<PoliticaVigente> {
    return POLITICA;
  }

  agregarPersona(datos: Partial<PersonaFalsa> = {}): PersonaFalsa {
    const persona: PersonaFalsa = {
      personaId: uuid(++this.contador),
      nombres: 'Luz Marina',
      apellidos: 'Chindoy',
      tipoDocumento: 'CC',
      numeroDocumento: `11240${this.contador}`,
      celular: `+5731500${String(this.contador).padStart(5, '0')}`,
      cuenta: 'ACTIVA',
      usuarioId: uuid(++this.contador),
      ...datos,
    };
    this.personas.push(persona);
    return persona;
  }

  /** QR personal vigente de la persona, como lo vería en su app. */
  qrPersonal(persona: PersonaFalsa, version = 1): string {
    const qrId = uuid(++this.contador);
    this.qrPersonales.forEach((q) => q.personaId === persona.personaId && (q.vigente = false));
    this.qrPersonales.push({ qrId, personaId: persona.personaId, version, vigente: true });
    return this.tokens.personal({ qrId, version, emitidoEn: new Date() });
  }

  async vistaPreviaQrPersonal(qrId: string): Promise<VistaPreviaQrPersonal | null> {
    const qr = this.qrPersonales.find((q) => q.qrId === qrId);
    const persona = qr && this.personas.find((p) => p.personaId === qr.personaId);
    if (!qr || !persona) return null;
    return { ...this.enmascarada(persona), version: qr.version, vigente: qr.vigente };
  }

  async qrDeAfiliacion(qrId: string) {
    const qr = this.qrAfiliacion.find((q) => q.qrId === qrId);
    return qr ? { clienteId: qr.clienteId, version: qr.version, vigente: qr.vigente } : null;
  }

  async personaPorDocumento(tipo: string, numero: string): Promise<PersonaEnVeci | null> {
    const p = this.personas.find((x) => x.tipoDocumento === tipo && x.numeroDocumento === numero);
    return p ? this.enmascarada(p) : null;
  }

  async cuentaPorCelular(celular: string): Promise<EstadoCuenta | null> {
    return this.personas.find((p) => p.celular === celular && p.usuarioId)?.cuenta ?? null;
  }

  async afiliar(a: NuevaAfiliacion): Promise<AfiliacionHecha> {
    let personaId = a.personaId as string;
    let usuarioCreado: string | null = null;
    if (a.personaNueva) {
      usuarioCreado = a.personaNueva.conCuenta ? uuid(++this.contador) : null;
      const cuenta = usuarioCreado ? 'PENDIENTE' : 'SIN_CUENTA';
      personaId = this.agregarPersona({
        ...a.personaNueva,
        cuenta,
        usuarioId: usuarioCreado,
      }).personaId;
    }
    if (a.politicaVersionId)
      this.consentimientos.push({ personaId, politicaVersionId: a.politicaVersionId });
    const ya = this.afiliaciones.find((x) => x.personaId === personaId);
    if (ya) return { clienteId: ya.clienteId, personaId, nueva: false, usuarioCreado };
    const clienteId = uuid(++this.contador);
    this.afiliaciones.push({ clienteId, personaId, canal: a.canal, en: new Date() });
    this.qrAfiliacion.push({ qrId: uuid(++this.contador), clienteId, version: 1, vigente: true });
    return { clienteId, personaId, nueva: true, usuarioCreado };
  }

  async buscar(consulta: ConsultaDeClientes): Promise<Cliente[]> {
    return this.todos().filter((c) =>
      consulta.tipo === 'NUMERO'
        ? `${c.numeroDocumento} ${c.celular}`.includes(consulta.digitos)
        : consulta.palabras.every((w) => plegar(`${c.nombres} ${c.apellidos ?? ''}`).includes(w)),
    );
  }

  async ficha(clienteId: string): Promise<Cliente | null> {
    return this.todos().find((c) => c.clienteId === clienteId) ?? null;
  }

  async usuarioDe(clienteId: string) {
    const afiliacion = this.afiliaciones.find((a) => a.clienteId === clienteId);
    const persona = this.personas.find((p) => p.personaId === afiliacion?.personaId);
    return persona ? { usuarioId: persona.usuarioId, cuenta: persona.cuenta } : null;
  }

  async versionDeCopia(): Promise<string> {
    return `${this.afiliaciones.length}`;
  }

  async copiaLocal(): Promise<CopiaLocal> {
    return { version: await this.versionDeCopia(), clientes: this.todos(), claves: [] };
  }

  private todos(): Cliente[] {
    return this.afiliaciones.map((a) => {
      const p = this.personas.find((x) => x.personaId === a.personaId) as PersonaFalsa;
      return {
        clienteId: a.clienteId,
        personaId: p.personaId,
        nombres: p.nombres,
        apellidos: p.apellidos,
        tipoDocumento: p.tipoDocumento,
        numeroDocumento: p.numeroDocumento,
        celular: p.celular,
        cuenta: p.cuenta,
        estado: 'ACTIVE',
        canal: a.canal as Cliente['canal'],
        afiliadoEn: a.en,
      };
    });
  }

  private enmascarada(p: PersonaFalsa): PersonaEnVeci {
    const clienteId = this.afiliaciones.find((a) => a.personaId === p.personaId)?.clienteId ?? null;
    const nombre = `${p.nombres} ${p.apellidos?.charAt(0) ?? ''}.`;
    const documento = `****${p.numeroDocumento.slice(-4)}`;
    return { personaId: p.personaId, nombre, documento, cuenta: p.cuenta, clienteId };
  }
}
