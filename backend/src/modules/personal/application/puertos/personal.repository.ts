import { EstadoMembresia, Miembro } from '../../domain/entities/miembro';
import { CupoDeCajeros } from '../../domain/rules/reglas-personal.rule';

/** Datos para dar de alta a alguien que aún no tiene cuenta en VECI. */
export interface PersonaNueva {
  celular: string;
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
}

/** Usuario que ya existe, encontrado por su celular o por su documento. */
export interface UsuarioEncontrado {
  usuarioId: string;
  /** Tiene un PIN propio (no temporal). */
  tienePinPropio: boolean;
}

export interface MembresiaExistente {
  membresiaId: string;
  estado: EstadoMembresia;
}

/** Rol con que entra la persona invitada: cajero (HU-02-04) o propietario (HU-03-01). */
export type RolInvitado = 'CASHIER' | 'OWNER';

/** Plan de la invitación: quién, y si hay que crear su cuenta o reactivar su membresía. */
export interface Invitacion {
  rol: RolInvitado;
  usuarioId: string | null;
  personaExistenteId: string | null;
  persona: PersonaNueva;
  membresiaRetirada: string | null;
  invitadoPor: string;
}

/** Equipo del comercio activo (tenancy.memberships). RLS limita todo al comercio. */
export interface PersonalRepository {
  listar(): Promise<Miembro[]>;
  buscar(membresiaId: string): Promise<Miembro | null>;
  cupoDeCajeros(): Promise<CupoDeCajeros>;
  buscarUsuarioPorCelular(celular: string): Promise<UsuarioEncontrado | null>;
  /** Persona con ese documento en toda la plataforma (búsqueda enmascarada) y su usuario. */
  buscarPorDocumento(
    tipo: string,
    numero: string,
  ): Promise<{ personaId: string; usuarioId: string | null } | null>;
  membresiaDe(usuarioId: string): Promise<MembresiaExistente | null>;
  /** Crea lo que falte (persona, usuario, membresía) y el rol invitado, en una transacción. */
  invitar(invitacion: Invitacion): Promise<{ membresiaId: string; usuarioId: string }>;
  cambiarEstado(membresiaId: string, estado: EstadoMembresia, porUsuarioId: string): Promise<void>;
}

export const PERSONAL_REPOSITORY = Symbol('PersonalRepository');
