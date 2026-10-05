import { Prisma } from '../../../../../generated/prisma/client';
import {
  CanalAfiliacion,
  Cliente,
  EstadoAfiliacion,
  EstadoCuenta,
} from '../../domain/entities/cliente';
import { ConsultaDeClientes } from '../../domain/rules/consulta-de-clientes.rule';
import { ESTADO_CUENTA } from './consultas-cuenta';

export interface FilaCliente {
  cliente_id: string;
  persona_id: string;
  nombres: string;
  apellidos: string | null;
  tipo_documento: string;
  numero_documento: string;
  celular: string | null;
  cuenta: EstadoCuenta;
  estado: EstadoAfiliacion;
  canal: CanalAfiliacion;
  afiliado_en: Date;
}

export function aCliente(f: FilaCliente): Cliente {
  return {
    clienteId: f.cliente_id,
    personaId: f.persona_id,
    nombres: f.nombres,
    apellidos: f.apellidos,
    tipoDocumento: f.tipo_documento,
    numeroDocumento: f.numero_documento,
    celular: f.celular,
    cuenta: f.cuenta,
    estado: f.estado,
    canal: f.canal,
    afiliadoEn: f.afiliado_en,
  };
}

/** Nombre sin tildes y en minúsculas, igual que plegar() del dominio. */
const NOMBRE_PLEGADO = Prisma.sql`
  translate(lower(p.given_names || ' ' || coalesce(p.family_names, '')),
            'áéíóúüñàèìòù', 'aeiouunaeiou')`;

/** Filtro de la búsqueda (HU-04-05): todas las palabras en el nombre, o dígitos en documento o celular. */
export function filtroDeBusqueda(consulta: ConsultaDeClientes): Prisma.Sql {
  if (consulta.tipo === 'NUMERO') {
    const patron = `%${consulta.digitos}%`;
    return Prisma.sql`(p.document_number LIKE ${patron}
      OR EXISTS (SELECT 1 FROM identity.person_contacts c
                  WHERE c.person_id = p.id AND regexp_replace(c.value, '\\D', '', 'g') LIKE ${patron}))`;
  }
  return Prisma.sql`NOT EXISTS (
    SELECT 1 FROM unnest(${[...consulta.palabras]}::text[]) w
     WHERE ${NOMBRE_PLEGADO} NOT LIKE '%' || w || '%')`;
}

/**
 * Clientes del comercio fijado: RLS deja ver solo sus afiliaciones y a esas personas.
 * La afiliación es el "cliente": su id es el que lleva el QR del comercio.
 */
export function consultaClientes(filtro: Prisma.Sql, limite: number | null): Prisma.Sql {
  const tope = limite === null ? Prisma.empty : Prisma.sql`LIMIT ${limite}`;
  return Prisma.sql`
    SELECT a.id::text AS cliente_id, p.id::text AS persona_id, p.given_names AS nombres,
           p.family_names AS apellidos, dt.code AS tipo_documento,
           p.document_number AS numero_documento,
           (SELECT c.value FROM identity.person_contacts c
              JOIN core.contact_types ct ON ct.id = c.contact_type_id AND ct.code = 'MOBILE_PHONE'
             WHERE c.person_id = p.id ORDER BY c.is_primary DESC, c.created_at LIMIT 1) AS celular,
           ${ESTADO_CUENTA} AS cuenta, st.code AS estado, ch.code AS canal,
           a.affiliated_at AS afiliado_en
      FROM customers.affiliations a
      JOIN identity.people p ON p.id = a.person_id
      JOIN core.document_types dt ON dt.id = p.document_type_id
      JOIN customers.affiliation_statuses st ON st.id = a.affiliation_status_id
      JOIN customers.affiliation_channels ch ON ch.id = a.affiliation_channel_id
      LEFT JOIN identity.users u ON u.person_id = p.id
      LEFT JOIN identity.user_statuses us ON us.id = u.user_status_id
     WHERE ${filtro}
     ORDER BY lower(p.given_names), lower(coalesce(p.family_names, '')), a.id
     ${tope}`;
}
