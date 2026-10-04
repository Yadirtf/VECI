import { Identidad } from '../../../../shared/application/contexto/identidad';
import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { VerificadorMembresia } from '../../../../shared/application/contexto/verificador-membresia.port';
import { Espacio, esPersonal } from '../../domain/entities/espacio';
import { SinAccesoAlComercio } from '../../domain/errors/sin-acceso-al-comercio.error';
import { EspaciosRepository } from '../puertos/espacios.repository';
import { ConsultarEspacios } from './consultar-espacios.use-case';

export interface DependenciasActivar {
  espacios: EspaciosRepository;
  consultar: ConsultarEspacios;
  membresias: VerificadorMembresia;
  auditoria: Auditoria;
}

export interface ComercioActivoOutput {
  comercio: Espacio;
  /** Lo que sus roles le permiten: la app y el panel muestran solo eso. */
  permisos: string[];
}

/**
 * Elige el comercio con el que se va a trabajar (HU-02-03). Acepta la invitación
 * pendiente de un cajero y deja el celular de la caja registrado (HU-02-06).
 */
export class ActivarComercio {
  constructor(private readonly d: DependenciasActivar) {}

  async ejecutar(identidad: Identidad, comercioId: string): Promise<ComercioActivoOutput> {
    const espacios = await this.d.consultar.deUsuario(identidad.usuarioId);
    const espacio = espacios.find((e) => e.comercioId === comercioId.toLowerCase());
    if (!espacio) throw new SinAccesoAlComercio();
    if (!esPersonal(espacio)) return { comercio: espacio, permisos: [] };
    if (espacio.invitacionPendiente) await this.aceptar(identidad, espacio.comercioId);
    if (identidad.dispositivoId) {
      await this.d.espacios.registrarDispositivoEnComercio(
        espacio.comercioId,
        identidad.dispositivoId,
        identidad.usuarioId,
      );
    }
    const permisos = await this.d.membresias.permisosEn(identidad.usuarioId, espacio.comercioId);
    return { comercio: { ...espacio, invitacionPendiente: false }, permisos: [...permisos].sort() };
  }

  private async aceptar(identidad: Identidad, comercioId: string): Promise<void> {
    await this.d.espacios.aceptarInvitacion(identidad.usuarioId, comercioId);
    await this.d.auditoria.registrar({
      accion: 'MEMBERSHIP_CHANGED',
      tabla: 'tenancy.memberships',
      entidadId: null,
      actorUsuarioId: identidad.usuarioId,
      comercioId,
      dispositivoId: identidad.dispositivoId,
      antes: { estado: 'INVITED' },
      despues: { estado: 'ACTIVE', usuarioId: identidad.usuarioId },
    });
  }
}
