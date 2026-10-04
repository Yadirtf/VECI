import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import {
  CuentaSoporte,
  CuentasSoporteRepository,
  PersonaPorDocumento,
} from '../../application/puertos/cuentas-soporte.repository';

/**
 * Busca sin contexto de comercio: identificadores y usuarios no tienen RLS, y la
 * persona por documento sale de customers.find_person_by_document (enmascarada).
 */
@Injectable()
export class PrismaCuentasSoporteRepository implements CuentasSoporteRepository {
  constructor(private readonly prisma: PrismaService) {}

  async buscarPorCelular(celular: string): Promise<CuentaSoporte | null> {
    const [fila] = await this.prisma.$queryRaw<{ usuario_id: string; persona_id: string }[]>`
      SELECT u.id::text AS usuario_id, u.person_id::text AS persona_id
        FROM identity.user_login_identifiers i
        JOIN core.contact_types ct ON ct.id = i.contact_type_id AND ct.code = 'MOBILE_PHONE'
        JOIN identity.users u ON u.id = i.user_id
       WHERE i.value = ${celular} AND i.revoked_at IS NULL`;
    return fila ? { usuarioId: fila.usuario_id, personaId: fila.persona_id } : null;
  }

  async buscarPorDocumento(tipo: string, numero: string): Promise<PersonaPorDocumento | null> {
    const [fila] = await this.prisma.$queryRaw<{ person_id: string; masked_name: string }[]>`
      SELECT person_id::text, masked_name
        FROM customers.find_person_by_document(${tipo}::varchar::core.catalog_code, ${numero}::varchar)`;
    return fila ? { personaId: fila.person_id, nombreEnmascarado: fila.masked_name } : null;
  }
}
