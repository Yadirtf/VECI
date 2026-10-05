import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { TransaccionUsuario } from '../../../../shared/infrastructure/prisma/transaccion-usuario';
import { ClaveDelComercio } from '../../application/puertos/clientes.repository';
import {
  ComercioDelCliente,
  MiQrRepository,
  QrDeAfiliacionGuardado,
  QrPersonalGuardado,
} from '../../application/puertos/mi-qr.repository';
import { asegurarQrDeAfiliacion } from './alta-de-cliente';
import { emitirQrPersonal } from './alta-de-persona';

interface FilaQr {
  qr_id: string;
  version: number;
  emitido_en: Date;
}

interface FilaComercio {
  comercio_id: string;
  cliente_id: string;
  nombre: string;
  tipo_negocio: string;
  afiliado_en: Date;
  qr_id: string | null;
  qr_version: number | null;
  key_id: string | null;
}

const aQr = (fila: FilaQr): QrPersonalGuardado => ({
  qrId: fila.qr_id,
  version: fila.version,
  emitidoEn: fila.emitido_en,
});

/**
 * Lo del cliente en su app. personal_qr_codes no tiene RLS y se filtra por la
 * persona de la sesión; sus comercios se leen con su contexto (customer_self).
 */
@Injectable()
export class PrismaMiQrRepository implements MiQrRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usuario: TransaccionUsuario,
    private readonly comercio: TransaccionComercio,
  ) {}

  /** Con el comercio de la afiliación fijado; la afiliación es de la persona de la sesión. */
  emitirQrDeAfiliacion(
    en: { comercioId: string; usuarioId: string },
    clienteId: string,
    clave: ClaveDelComercio,
  ): Promise<QrDeAfiliacionGuardado> {
    return this.comercio.ejecutarComo(en, (tx) => asegurarQrDeAfiliacion(tx, clienteId, clave));
  }

  async personaDe(usuarioId: string): Promise<string> {
    const [fila] = await this.prisma.$queryRaw<{ persona_id: string }[]>`
      SELECT person_id::text AS persona_id FROM identity.users WHERE id = ${usuarioId}::uuid`;
    if (!fila) throw new Error(`El usuario ${usuarioId} de la sesión no existe.`);
    return fila.persona_id;
  }

  async vigente(personaId: string): Promise<QrPersonalGuardado | null> {
    const [fila] = await this.prisma.$queryRaw<FilaQr[]>`
      SELECT id::text AS qr_id, version, issued_at AS emitido_en
        FROM customers.personal_qr_codes
       WHERE person_id = ${personaId}::uuid AND revoked_at IS NULL`;
    return fila ? aQr(fila) : null;
  }

  async emitirPrimero(personaId: string): Promise<QrPersonalGuardado> {
    return aQr(await this.prisma.$transaction((tx) => emitirQrPersonal(tx, personaId)));
  }

  async regenerar(personaId: string): Promise<QrPersonalGuardado> {
    return this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`
        UPDATE customers.personal_qr_codes
           SET revoked_at = now(),
               revocation_reason_id = (SELECT id FROM core.qr_revocation_reasons WHERE code = 'REGENERATED')
         WHERE person_id = ${personaId}::uuid AND revoked_at IS NULL`;
      return aQr(await emitirQrPersonal(tx, personaId));
    });
  }

  async comercios(usuarioId: string, personaId: string): Promise<ComercioDelCliente[]> {
    const filas = await this.usuario.ejecutarComo(
      { usuarioId, personaId },
      (tx) => tx.$queryRaw<FilaComercio[]>`
        SELECT a.tenant_id::text AS comercio_id, a.id::text AS cliente_id, t.display_name AS nombre,
               bt.code AS tipo_negocio, a.affiliated_at AS afiliado_en, q.id::text AS qr_id,
               q.version AS qr_version, k.key_id
          FROM customers.affiliations a
          JOIN customers.affiliation_statuses st ON st.id = a.affiliation_status_id
                                                AND st.allows_operations
          JOIN tenancy.tenants t ON t.id = a.tenant_id
          JOIN tenancy.business_types bt ON bt.id = t.business_type_id
          LEFT JOIN customers.affiliation_qr_codes q ON q.affiliation_id = a.id AND q.revoked_at IS NULL
          LEFT JOIN tenancy.tenant_signing_keys k ON k.id = q.signing_key_id
         WHERE a.person_id = core.current_person_id()
         ORDER BY a.affiliated_at DESC`,
    );
    return filas.map((f) => ({
      comercioId: f.comercio_id,
      clienteId: f.cliente_id,
      nombre: f.nombre,
      tipoNegocio: f.tipo_negocio,
      afiliadoEn: f.afiliado_en,
      qr:
        f.qr_id && f.qr_version && f.key_id
          ? { qrId: f.qr_id, version: f.qr_version, keyId: f.key_id }
          : null,
    }));
  }
}
