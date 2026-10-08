import { EntradaAuditoria } from '../../../../shared/application/puertos/auditoria.port';
import { EstadoSolicitud, SolicitudDeNegocio } from '../../domain/entities/solicitud';
import { SolicitudEnRevision } from '../../domain/errors/errores-solicitudes';
import { AltaDeComercio } from '../puertos/comercios.repository';
import { NuevaSolicitud, SolicitudesRepository } from '../puertos/solicitudes.repository';
import { ComerciosEnMemoria } from './comercios-en-memoria.fake';
import { RegistrarComercio } from './registrar-comercio.use-case';
import { RevisarSolicitudes } from './revisar-solicitudes.use-case';
import { SolicitarRegistroDeNegocio } from './solicitar-registro.use-case';

/** Solicitudes en memoria: guarda lo radicado y decide una sola vez. */
class SolicitudesEnMemoria implements SolicitudesRepository {
  readonly filas = new Map<string, SolicitudDeNegocio>();
  readonly aprobadas: AltaDeComercio[] = [];

  async radicar({ solicitudId, solicitanteId, alta }: NuevaSolicitud): Promise<void> {
    const abierta = [...this.filas.values()].some(
      (s) => s.solicitante.usuarioId === solicitanteId && s.estado === 'PENDING',
    );
    if (abierta) throw new SolicitudEnRevision();
    this.filas.set(solicitudId, {
      solicitudId,
      estado: 'PENDING',
      nombre: alta.nombre.valor,
      tipoNegocio: alta.tipoNegocio,
      tipoDocumento: alta.documento.tipo,
      numeroDocumento: alta.documento.numero,
      celular: alta.celular,
      correo: alta.correo,
      logoUrl: alta.logoUrl,
      municipioId: alta.municipioId ?? 0,
      municipio: 'Mocoa',
      direccion: alta.direccion,
      solicitante: { usuarioId: solicitanteId, nombre: 'Rosa', celular: null },
      nota: null,
      comercioId: null,
      radicadaEn: new Date(),
      revisadaEn: null,
    });
  }

  async mias(usuarioId: string) {
    return [...this.filas.values()].filter((s) => s.solicitante.usuarioId === usuarioId);
  }

  async listar(_revisor: string, estado: EstadoSolicitud | null) {
    return [...this.filas.values()].filter((s) => !estado || s.estado === estado);
  }

  async buscar(_revisor: string, id: string) {
    return this.filas.get(id) ?? null;
  }

  async aprobar(_revisor: string, id: string, alta: AltaDeComercio) {
    if (!this.decidir(id, 'APPROVED', null, alta.comercioId)) return null;
    this.aprobadas.push(alta);
    return alta.nombre.slug;
  }

  async rechazar(_revisor: string, id: string, motivo: string) {
    return this.decidir(id, 'REJECTED', motivo, null);
  }

  private decidir(
    id: string,
    estado: EstadoSolicitud,
    nota: string | null,
    comercio: string | null,
  ) {
    const fila = this.filas.get(id);
    if (fila?.estado !== 'PENDING') return false;
    this.filas.set(id, { ...fila, estado, nota, comercioId: comercio, revisadaEn: new Date() });
    return true;
  }
}

describe('Solicitudes para registrar un negocio', () => {
  let solicitudes: SolicitudesEnMemoria;
  let auditoria: EntradaAuditoria[];
  let solicitar: SolicitarRegistroDeNegocio;
  let revisar: RevisarSolicitudes;
  let siguiente: number;
  const entrada = {
    nombre: 'Asadero El Vecino',
    tipoNegocio: 'RESTAURANT',
    tipoDocumento: 'NIT',
    numeroDocumento: '800197268',
    celular: '310 000 0101',
    municipioId: 86001,
  };

  beforeEach(() => {
    solicitudes = new SolicitudesEnMemoria();
    auditoria = [];
    siguiente = 0;
    const ids = { siguiente: () => `id-${++siguiente}` };
    const bitacora = { registrar: async (e: EntradaAuditoria) => void auditoria.push(e) };
    const comercios = new ComerciosEnMemoria();
    const registrar = new RegistrarComercio({ comercios, ids, auditoria: bitacora });
    solicitar = new SolicitarRegistroDeNegocio({
      solicitudes,
      registrar,
      ids,
      auditoria: bitacora,
    });
    revisar = new RevisarSolicitudes({ solicitudes, registrar, auditoria: bitacora });
  });

  const radicada = async (usuarioId = 'rosa') => {
    await solicitar.ejecutar(usuarioId, entrada);
    const [solicitud] = await solicitar.mias(usuarioId);
    return solicitud;
  };

  it('radica con los datos validados como un alta y queda en revisión', async () => {
    const solicitud = await radicada();
    expect(solicitud).toMatchObject({ estado: 'PENDING', numeroDocumento: '8001972684' });
    expect(auditoria).toEqual([
      expect.objectContaining({ accion: 'BUSINESS_APPLICATION_SUBMITTED', comercioId: null }),
    ]);
    await expect(solicitar.ejecutar('rosa', entrada)).rejects.toThrow('en revisión');
  });

  it('exige municipio y que VECI opere en él', async () => {
    const sinMunicipio = { ...entrada, municipioId: undefined as unknown as number };
    await expect(solicitar.ejecutar('rosa', sinMunicipio)).rejects.toThrow('municipio');
    await expect(solicitar.ejecutar('rosa', { ...entrada, municipioId: 86568 })).rejects.toThrow(
      'Mocoa',
    );
  });

  it('al aprobar nace el negocio con quien lo pidió como propietaria, una sola vez', async () => {
    const { solicitudId } = await radicada();
    const aprobado = await revisar.aprobar('admin', solicitudId);
    expect(solicitudes.aprobadas[0]).toMatchObject({ propietarioId: 'rosa', creadoPor: 'admin' });
    expect(aprobado.slug).toBe('asadero-el-vecino');
    expect(auditoria.map((e) => e.accion)).toEqual([
      'BUSINESS_APPLICATION_SUBMITTED',
      'BUSINESS_APPLICATION_REVIEWED',
      'TENANT_CREATED',
    ]);
    await expect(revisar.aprobar('admin', solicitudId)).rejects.toThrow('ya fue revisada');
    await expect(revisar.aprobar('admin', 'otra')).rejects.toThrow('No encontramos');
  });

  it('al rechazar exige el motivo y deja volver a pedirlo', async () => {
    const { solicitudId } = await radicada();
    await expect(revisar.rechazar('admin', solicitudId, ' corto ')).rejects.toThrow('por qué');
    await revisar.rechazar('admin', solicitudId, 'El NIT no es del negocio, revísalo.');
    expect(await revisar.listar('admin', 'REJECTED')).toEqual([
      expect.objectContaining({ nota: 'El NIT no es del negocio, revísalo.' }),
    ]);
    await expect(
      revisar.rechazar('admin', solicitudId, 'Otra vez el mismo motivo largo'),
    ).rejects.toThrow('ya fue revisada');
    await expect(radicada()).resolves.toBeDefined();
  });

  it('si otra persona la decidió al mismo tiempo, no crea nada', async () => {
    const { solicitudId } = await radicada();
    jest.spyOn(solicitudes, 'aprobar').mockResolvedValueOnce(null);
    await expect(revisar.aprobar('admin', solicitudId)).rejects.toThrow('ya fue revisada');
    jest.spyOn(solicitudes, 'rechazar').mockResolvedValueOnce(false);
    await expect(
      revisar.rechazar('admin', solicitudId, 'Motivo suficientemente largo'),
    ).rejects.toThrow('ya fue revisada');
  });
});
