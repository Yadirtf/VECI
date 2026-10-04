import { CABECERA_COMERCIO } from '@/shared/api/cabeceras';
import type { ClienteVeci, components } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import type {
  AccionMiembro,
  DatosInvitacion,
  Dispositivo,
  Invitacion,
  Miembro,
  RepositorioEquipo,
} from '../domain/equipo';

type DispositivoApi = components['schemas']['DispositivoResponse'];

const falla = (error: unknown) => new Error(leerProblema(error).mensaje);

const aDispositivo = (d: DispositivoApi): Dispositivo => ({
  dispositivoId: d.dispositivoId,
  nombre: d.nombre ?? null,
  plataforma: d.plataforma,
  ultimaVez: new Date(d.ultimaVez),
  sesiones: d.sesiones.map((s) => ({
    sesionId: s.sesionId,
    nombre: s.nombre,
    ultimoUso: new Date(s.ultimoUso),
  })),
});

/** Equipo y dispositivos con el cliente generado desde OpenAPI. */
export class RepositorioEquipoApi implements RepositorioEquipo {
  constructor(
    private readonly cliente: ClienteVeci,
    private readonly comercioId: string,
  ) {}

  private get cabecera() {
    return { header: { [CABECERA_COMERCIO]: this.comercioId } };
  }

  async listar(): Promise<Miembro[]> {
    const { data, error } = await this.cliente.GET('/equipo', { params: this.cabecera });
    if (!data) throw falla(error);
    return data.map((m) => ({
      ...m,
      celular: m.celular ?? null,
      estado: m.estado as Miembro['estado'],
    }));
  }

  async invitar(datos: DatosInvitacion): Promise<Invitacion> {
    const { data, error } = await this.cliente.POST('/equipo/cajeros', {
      params: this.cabecera,
      body: datos,
    });
    if (!data) throw falla(error);
    return { membresiaId: data.membresiaId, pinTemporal: data.pinTemporal ?? null };
  }

  async cambiarEstado(membresiaId: string, accion: AccionMiembro): Promise<void> {
    const { error } = await this.cliente.PATCH('/equipo/{membresiaId}/estado', {
      params: { ...this.cabecera, path: { membresiaId } },
      body: { accion },
    });
    if (error) throw falla(error);
  }

  async restablecerPin(membresiaId: string): Promise<string> {
    const { data, error } = await this.cliente.POST('/equipo/{membresiaId}/restablecer-pin', {
      params: { ...this.cabecera, path: { membresiaId } },
    });
    if (!data) throw falla(error);
    return data.pinTemporal;
  }

  async dispositivos(): Promise<Dispositivo[]> {
    const { data, error } = await this.cliente.GET('/dispositivos', { params: this.cabecera });
    if (!data) throw falla(error);
    return data.map(aDispositivo);
  }

  async cerrarSesiones(dispositivoId: string): Promise<number> {
    const { data, error } = await this.cliente.POST('/dispositivos/{dispositivoId}/cerrar-sesion', {
      params: { ...this.cabecera, path: { dispositivoId } },
    });
    if (!data) throw falla(error);
    return data.sesionesCerradas;
  }
}
