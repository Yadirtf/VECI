import { Prisma } from '../../../../../generated/prisma/client';
import { EstadoSolicitud, SolicitudDeNegocio } from '../../domain/entities/solicitud';

export interface FilaSolicitud {
  solicitud_id: string;
  estado: EstadoSolicitud;
  nombre: string;
  tipo_negocio: string;
  tipo_documento: string;
  numero_documento: string;
  celular: string;
  correo: string | null;
  logo_url: string | null;
  municipio_id: number;
  municipio: string;
  direccion: string | null;
  solicitante_id: string;
  solicitante_nombre: string | null;
  solicitante_celular: string | null;
  nota: string | null;
  comercio_id: string | null;
  radicada_en: Date;
  revisada_en: Date | null;
}

/**
 * Solicitudes con sus catálogos. El nombre de quien pide sale de identity.people,
 * que RLS solo muestra a Administración VECI (platform_sees_applicants) o a ella misma.
 */
export function consultaSolicitudes(filtro: Prisma.Sql): Prisma.Sql {
  return Prisma.sql`
    SELECT b.id::text AS solicitud_id, st.code AS estado, b.display_name AS nombre,
           bt.code AS tipo_negocio, dt.code AS tipo_documento, b.document_number AS numero_documento,
           b.contact_phone AS celular, b.contact_email AS correo, b.logo_url,
           b.municipality_id AS municipio_id, mu.name AS municipio, b.address_line AS direccion,
           b.applicant_user_id::text AS solicitante_id,
           trim(p.given_names || ' ' || coalesce(p.family_names, '')) AS solicitante_nombre,
           (SELECT i.value FROM identity.user_login_identifiers i
              JOIN core.contact_types ct ON ct.id = i.contact_type_id AND ct.code = 'MOBILE_PHONE'
             WHERE i.user_id = b.applicant_user_id AND i.revoked_at IS NULL
             LIMIT 1) AS solicitante_celular,
           b.review_note AS nota, b.tenant_id::text AS comercio_id,
           b.created_at AS radicada_en,
           CASE WHEN b.reviewed_by_user_id IS NULL THEN NULL ELSE b.status_changed_at END AS revisada_en
      FROM tenancy.business_applications b
      JOIN tenancy.business_application_statuses st ON st.id = b.business_application_status_id
      JOIN tenancy.business_types bt ON bt.id = b.business_type_id
      JOIN core.document_types dt ON dt.id = b.document_type_id
      JOIN core.municipalities mu ON mu.id = b.municipality_id
      JOIN identity.users u ON u.id = b.applicant_user_id
      LEFT JOIN identity.people p ON p.id = u.person_id
     WHERE ${filtro}
     ORDER BY b.created_at DESC`;
}

export const aSolicitud = (f: FilaSolicitud): SolicitudDeNegocio => ({
  solicitudId: f.solicitud_id,
  estado: f.estado,
  nombre: f.nombre,
  tipoNegocio: f.tipo_negocio,
  tipoDocumento: f.tipo_documento,
  numeroDocumento: f.numero_documento,
  celular: f.celular,
  correo: f.correo,
  logoUrl: f.logo_url,
  municipioId: f.municipio_id,
  municipio: f.municipio,
  direccion: f.direccion,
  solicitante: {
    usuarioId: f.solicitante_id,
    nombre: f.solicitante_nombre ?? '',
    celular: f.solicitante_celular,
  },
  nota: f.nota,
  comercioId: f.comercio_id,
  radicadaEn: f.radicada_en,
  revisadaEn: f.revisada_en,
});
