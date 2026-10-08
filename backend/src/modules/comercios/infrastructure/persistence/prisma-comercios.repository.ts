import { Inject, Injectable } from '@nestjs/common';
import {
  GENERADOR_IDS,
  GeneradorIds,
} from '../../../../shared/application/puertos/generador-ids.port';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';
import {
  ClienteTransaccion,
  TransaccionComercio,
} from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { PerfilComercio } from '../../domain/entities/comercio';
import {
  AltaDeComercio,
  CambiosComercio,
  ComerciosRepository,
  Municipio,
  TipoDeNegocio,
} from '../../application/puertos/comercios.repository';
import {
  crearComercio,
  crearContactos,
  crearPropietario,
  crearSedeYServicios,
  iniciarPrueba,
} from './alta-de-comercio';
import { aPerfil, CONSULTA_PERFIL, FilaPerfil } from './consultas-comercio';

interface FilaTipo {
  codigo: string;
  nombre: string;
  servicios: { nombre: string; horaInicio: string; horaFin: string }[];
}

/**
 * Comercios en tenancy. El alta corre con el id nuevo ya fijado como comercio
 * activo: así RLS acepta cada fila sin abrir permisos de plataforma.
 */
@Injectable()
export class PrismaComerciosRepository implements ComerciosRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly transaccion: TransaccionComercio,
    @Inject(GENERADOR_IDS) private readonly ids: GeneradorIds,
  ) {}

  /** Catálogos sin RLS: tipos de negocio con sus servicios sugeridos. */
  tiposDeNegocio(): Promise<TipoDeNegocio[]> {
    return this.prisma.$queryRaw<FilaTipo[]>`
      SELECT bt.code AS codigo, bt.name AS nombre,
             coalesce(json_agg(json_build_object(
               'nombre', s.name,
               'horaInicio', to_char(lower(s.suggested_hours), 'HH24:MI'),
               'horaFin', to_char(upper(s.suggested_hours), 'HH24:MI')) ORDER BY s.sort_order)
               FILTER (WHERE s.name IS NOT NULL), '[]') AS servicios
        FROM tenancy.business_types bt
        LEFT JOIN tenancy.business_type_services s ON s.business_type_id = bt.id
       WHERE bt.is_active
       GROUP BY bt.id
       ORDER BY bt.sort_order`;
  }

  municipios(): Promise<Municipio[]> {
    return this.prisma.$queryRaw<Municipio[]>`
      SELECT id, name AS nombre FROM core.municipalities WHERE is_served ORDER BY name`;
  }

  registrar(alta: AltaDeComercio): Promise<string> {
    const contexto = { comercioId: alta.comercioId, usuarioId: alta.creadoPor };
    return this.transaccion.ejecutarComo(contexto, async (tx) => {
      const slug = await crearComercio(tx, alta);
      await crearContactos(tx, alta);
      await crearSedeYServicios(tx, alta);
      await crearPropietario(tx, alta, this.ids.siguiente());
      await iniciarPrueba(tx);
      return slug;
    });
  }

  perfil(): Promise<PerfilComercio> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<FilaPerfil[]>(CONSULTA_PERFIL);
      return aPerfil(fila);
    });
  }

  actualizar(c: CambiosComercio): Promise<void> {
    return this.transaccion.ejecutar(async (tx) => {
      await tx.$executeRaw`
        UPDATE tenancy.tenants
           SET display_name = coalesce(${c.nombre?.valor ?? null}, display_name),
               business_type_id = coalesce((SELECT id FROM tenancy.business_types
                                             WHERE code = ${c.tipoNegocio ?? null} AND is_active),
                                           business_type_id),
               logo_url = CASE WHEN ${c.logoUrl !== undefined} THEN ${c.logoUrl ?? null} ELSE logo_url END
         WHERE id = core.current_tenant_id()`;
      if (c.celular) await this.cambiarContacto(tx, 'MOBILE_PHONE', c.celular);
      if (c.correo !== undefined) await this.cambiarContacto(tx, 'EMAIL', c.correo);
    });
  }

  abrir(): Promise<void> {
    return this.transaccion.ejecutar(async (tx) => {
      const cambiadas = await tx.$executeRaw`
        UPDATE tenancy.tenants
           SET tenant_status_id = (SELECT id FROM tenancy.tenant_statuses WHERE code = 'ACTIVE')
         WHERE id = core.current_tenant_id()`;
      if (cambiadas === 0) throw new DatoInvalido('No encontramos tu negocio, veci.');
    });
  }

  /** El contacto principal anterior deja de serlo; nada se borra. */
  private async cambiarContacto(
    tx: ClienteTransaccion,
    tipo: 'MOBILE_PHONE' | 'EMAIL',
    valor: string | null,
  ): Promise<void> {
    await tx.$executeRaw`
      UPDATE tenancy.tenant_contacts SET is_primary = false
       WHERE is_primary AND contact_type_id = (SELECT id FROM core.contact_types WHERE code = ${tipo})`;
    if (valor === null) return;
    await tx.$executeRaw`
      INSERT INTO tenancy.tenant_contacts (tenant_id, contact_type_id, value, is_primary)
      SELECT core.current_tenant_id(), ct.id, ${valor}, true FROM core.contact_types ct
       WHERE ct.code = ${tipo}
      ON CONFLICT (tenant_id, contact_type_id, value) DO UPDATE SET is_primary = true`;
  }
}
