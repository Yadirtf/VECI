import { EntradaAuditoria } from '../../../../shared/application/puertos/auditoria.port';
import { EmitirPinTemporal } from '../../../autenticacion';
import { EstadoMembresia, Miembro } from '../../domain/entities/miembro';
import { Invitacion, PersonalRepository, UsuarioEncontrado } from '../puertos/personal.repository';

/** Equipo en memoria para probar los casos de uso sin base de datos. */
export class PersonalEnMemoria implements PersonalRepository {
  readonly miembros: Miembro[] = [];
  readonly usuarios = new Map<string, UsuarioEncontrado>();
  readonly documentos = new Map<string, { personaId: string; usuarioId: string | null }>();
  readonly invitaciones: Invitacion[] = [];
  readonly auditoria: EntradaAuditoria[] = [];
  readonly pines: unknown[] = [];
  limite: number | null = 2;
  private contador = 0;

  readonly bitacora = { registrar: async (e: EntradaAuditoria) => void this.auditoria.push(e) };
  readonly pinTemporal = {
    ejecutar: async (entrada: unknown) => {
      this.pines.push(entrada);
      return '730284';
    },
  } as unknown as EmitirPinTemporal;

  async listar(): Promise<Miembro[]> {
    return this.miembros;
  }

  async buscar(membresiaId: string): Promise<Miembro | null> {
    return this.miembros.find((m) => m.membresiaId === membresiaId) ?? null;
  }

  async cupoDeCajeros() {
    const ocupan = this.miembros.filter(
      (m) => m.roles.includes('CASHIER') && ['ACTIVE', 'INVITED'].includes(m.estado),
    );
    return { ocupados: ocupan.length, limite: this.limite };
  }

  async buscarUsuarioPorCelular(celular: string) {
    return this.usuarios.get(celular) ?? null;
  }

  async buscarPorDocumento(tipo: string, numero: string) {
    return this.documentos.get(`${tipo}:${numero}`) ?? null;
  }

  async membresiaDe(usuarioId: string) {
    const miembro = this.miembros.find((m) => m.usuarioId === usuarioId);
    return miembro ? { membresiaId: miembro.membresiaId, estado: miembro.estado } : null;
  }

  async invitar(invitacion: Invitacion) {
    this.invitaciones.push(invitacion);
    const usuarioId = invitacion.usuarioId ?? `nuevo-${++this.contador}`;
    const membresiaId = invitacion.membresiaRetirada ?? `m-${++this.contador}`;
    const sinRetirada = this.miembros.filter((m) => m.membresiaId !== membresiaId);
    this.miembros.splice(0, this.miembros.length, ...sinRetirada, {
      membresiaId,
      usuarioId,
      nombre: invitacion.persona.nombres,
      celular: invitacion.persona.celular,
      estado: 'INVITED',
      roles: [invitacion.rol],
    });
    return { membresiaId, usuarioId };
  }

  async cambiarEstado(membresiaId: string, estado: EstadoMembresia): Promise<void> {
    const i = this.miembros.findIndex((m) => m.membresiaId === membresiaId);
    this.miembros[i] = { ...this.miembros[i], estado };
  }
}
