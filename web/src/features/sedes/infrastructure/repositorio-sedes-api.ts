import { CABECERA_COMERCIO } from '@/shared/api/cabeceras';
import type { ClienteVeci } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import type { MapaDeSedes, RepositorioSedes } from '../domain/sede';

const falla = (error: unknown) => new Error(leerProblema(error).mensaje);

/** Sedes y cajeros por sede con el cliente generado desde OpenAPI (HU-03-03). */
export class RepositorioSedesApi implements RepositorioSedes {
  constructor(
    private readonly cliente: ClienteVeci,
    private readonly comercioId: string,
  ) {}

  private get params() {
    return { header: { [CABECERA_COMERCIO]: this.comercioId } };
  }

  async mapa(): Promise<MapaDeSedes> {
    const { data, error } = await this.cliente.GET('/sedes', { params: this.params });
    if (!data) throw falla(error);
    return {
      sedes: data.sedes.map((s) => ({
        id: s.sedeId,
        nombre: s.nombre,
        principal: s.principal,
        activa: s.activa,
        municipio: s.municipio ?? null,
        direccion: s.direccion ?? null,
      })),
      cajeros: data.cajeros,
      cupo: { ...data.cupo, limite: data.cupo.limite ?? null },
    };
  }

  async crear(nombre: string, direccion: string | null): Promise<void> {
    const { error } = await this.cliente.POST('/sedes', {
      params: this.params,
      body: { nombre, direccion },
    });
    if (error) throw falla(error);
  }

  async cambiarActiva(sedeId: string, activa: boolean): Promise<void> {
    const { error } = await this.cliente.PATCH('/sedes/{sedeId}', {
      params: { ...this.params, path: { sedeId } },
      body: { activa },
    });
    if (error) throw falla(error);
  }

  async asignar(membresiaId: string, sedeIds: string[]): Promise<void> {
    const { error } = await this.cliente.PUT('/sedes/cajeros/{membresiaId}', {
      params: { ...this.params, path: { membresiaId } },
      body: { sedeIds },
    });
    if (error) throw falla(error);
  }
}
