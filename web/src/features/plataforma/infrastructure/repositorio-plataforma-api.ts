import type { ClienteVeci } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import type { RepositorioPlataforma, SolicitudPorRevisar } from '../domain/solicitud';

const falla = (error: unknown) => new Error(leerProblema(error).mensaje);

/** Consola VECI con el cliente generado desde OpenAPI; el API exige platform.manage_tenants. */
export class RepositorioPlataformaApi implements RepositorioPlataforma {
  constructor(private readonly cliente: ClienteVeci) {}

  async pendientes(): Promise<SolicitudPorRevisar[]> {
    const { data, error } = await this.cliente.GET('/plataforma/solicitudes-de-negocio', {
      params: { query: { estado: 'PENDING' } },
    });
    if (!data) throw falla(error);
    return data.map((s) => ({
      solicitudId: s.solicitudId,
      nombre: s.nombre,
      tipoNegocio: s.tipoNegocio,
      tipoDocumento: s.tipoDocumento,
      numeroDocumento: s.numeroDocumento,
      celular: s.celular,
      correo: s.correo ?? null,
      municipio: s.municipio,
      direccion: s.direccion ?? null,
      solicitante: { nombre: s.solicitante.nombre, celular: s.solicitante.celular ?? null },
      radicadaEn: new Date(s.radicadaEn),
    }));
  }

  async aprobar(solicitudId: string): Promise<void> {
    const { error } = await this.cliente.POST(
      '/plataforma/solicitudes-de-negocio/{solicitudId}/aprobacion',
      { params: { path: { solicitudId } } },
    );
    if (error) throw falla(error);
  }

  async rechazar(solicitudId: string, motivo: string): Promise<void> {
    const { error } = await this.cliente.POST(
      '/plataforma/solicitudes-de-negocio/{solicitudId}/rechazo',
      { params: { path: { solicitudId } }, body: { motivo } },
    );
    if (error) throw falla(error);
  }
}
