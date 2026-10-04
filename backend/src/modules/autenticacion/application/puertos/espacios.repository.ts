import { RolEnComercio } from '../../domain/entities/espacio';

/** Comercios donde el usuario trabaja o es cliente (HU-02-03). */
export interface EspaciosRepository {
  listar(usuarioId: string, personaId: string): Promise<RolEnComercio[]>;
  /** La primera vez que un cajero invitado entra al comercio, su membresía queda activa. */
  aceptarInvitacion(usuarioId: string, comercioId: string): Promise<void>;
  /** El celular de la caja queda como dispositivo del negocio (HU-02-06). */
  registrarDispositivoEnComercio(
    comercioId: string,
    dispositivoId: string,
    usuarioId: string,
  ): Promise<void>;
}

export const ESPACIOS_REPOSITORY = Symbol('EspaciosRepository');
