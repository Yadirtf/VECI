import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../generated/prisma/client';
import {
  GENERADOR_IDS,
  GeneradorIds,
} from '../../../../shared/application/puertos/generador-ids.port';
import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';
import { TransaccionComercio } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { Cliente, EstadoCuenta } from '../../domain/entities/cliente';
import { CelularEnUso } from '../../domain/errors/errores-clientes';
import { ConsultaDeClientes } from '../../domain/rules/consulta-de-clientes.rule';
import {
  AfiliacionHecha,
  ClientesRepository,
  CopiaLocal,
  NuevaAfiliacion,
  PersonaEnVeci,
  VistaPreviaQrPersonal,
} from '../../application/puertos/clientes.repository';
import { codigoPostgres, VIOLACION_UNICA } from './alta-de-persona';
import { afiliar } from './alta-de-cliente';
import { aCliente, consultaClientes, FilaCliente, filtroDeBusqueda } from './consultas-clientes';
import {
  consultaCuentaPorCelular,
  consultaPersonaPorDocumento,
  ESTADO_CUENTA,
  FilaPersonaGlobal,
} from './consultas-cuenta';

/** Máximo de resultados por búsqueda: en la caja se afina escribiendo más. */
const LIMITE_BUSQUEDA = 50;
const VIGENTES = Prisma.sql`st.code <> 'ENDED'`;

/** Clientes del comercio activo (HU-04-03 a HU-04-05). Todo corre con el comercio fijado (RLS). */
@Injectable()
export class PrismaClientesRepository implements ClientesRepository {
  constructor(
    private readonly transaccion: TransaccionComercio,
    @Inject(GENERADOR_IDS) private readonly ids: GeneradorIds,
  ) {}

  vistaPreviaQrPersonal(qrId: string): Promise<VistaPreviaQrPersonal | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<
        (FilaPersonaGlobal & { version: number; vigente: boolean; cliente_id: string | null })[]
      >`
        SELECT f.person_id::text AS persona_id, f.masked_name AS nombre, f.masked_document AS documento,
               f.version, f.is_current AS vigente, ${ESTADO_CUENTA} AS cuenta,
               (SELECT a.id::text FROM customers.affiliations a WHERE a.person_id = f.person_id) AS cliente_id
          FROM customers.preview_personal_qr(${qrId}::uuid) f
          LEFT JOIN identity.users u ON u.person_id = f.person_id
          LEFT JOIN identity.user_statuses us ON us.id = u.user_status_id`;
      if (!fila) return null;
      return { ...aPersona(fila, fila.cliente_id), version: fila.version, vigente: fila.vigente };
    });
  }

  qrDeAfiliacion(qrId: string) {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<
        { cliente_id: string; version: number; vigente: boolean }[]
      >`
        SELECT affiliation_id::text AS cliente_id, version, revoked_at IS NULL AS vigente
          FROM customers.affiliation_qr_codes WHERE id = ${qrId}::uuid`;
      return fila
        ? { clienteId: fila.cliente_id, version: fila.version, vigente: fila.vigente }
        : null;
    });
  }

  personaPorDocumento(tipo: string, numero: string): Promise<PersonaEnVeci | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<FilaPersonaGlobal[]>(
        consultaPersonaPorDocumento(tipo, numero),
      );
      if (!fila) return null;
      const [cliente] = await tx.$queryRaw<{ id: string }[]>`
        SELECT id::text FROM customers.affiliations WHERE person_id = ${fila.persona_id}::uuid`;
      return aPersona(fila, cliente?.id ?? null);
    });
  }

  cuentaPorCelular(celular: string): Promise<EstadoCuenta | null> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ cuenta: EstadoCuenta }[]>(
        consultaCuentaPorCelular(celular),
      );
      return fila?.cuenta ?? null;
    });
  }

  async afiliar(afiliacion: NuevaAfiliacion): Promise<AfiliacionHecha> {
    try {
      return await this.transaccion.ejecutar((tx) => afiliar(tx, afiliacion, this.ids));
    } catch (error) {
      if (error instanceof ErrorDeDominio) throw error;
      // El celular se volvió entrada de otra cuenta entre la revisión y el registro.
      if (codigoPostgres(error) === VIOLACION_UNICA) throw new CelularEnUso();
      throw error;
    }
  }

  buscar(consulta: ConsultaDeClientes): Promise<Cliente[]> {
    const filtro = Prisma.sql`${VIGENTES} AND ${filtroDeBusqueda(consulta)}`;
    return this.clientes(filtro, LIMITE_BUSQUEDA);
  }

  async ficha(clienteId: string): Promise<Cliente | null> {
    const [cliente] = await this.clientes(Prisma.sql`a.id = ${clienteId}::uuid`, 1);
    return cliente ?? null;
  }

  usuarioDe(clienteId: string) {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ usuario_id: string | null; cuenta: EstadoCuenta }[]>`
        SELECT u.id::text AS usuario_id, ${ESTADO_CUENTA} AS cuenta
          FROM customers.affiliations a
          LEFT JOIN identity.users u ON u.person_id = a.person_id
          LEFT JOIN identity.user_statuses us ON us.id = u.user_status_id
         WHERE a.id = ${clienteId}::uuid`;
      return fila ? { usuarioId: fila.usuario_id, cuenta: fila.cuenta } : null;
    });
  }

  versionDeCopia(): Promise<string> {
    return this.transaccion.ejecutar(async (tx) => {
      const [fila] = await tx.$queryRaw<{ version: string }[]>`
        SELECT coalesce(max(sync_version), 0)::text || '.' || count(*)::text AS version
          FROM customers.affiliations`;
      return fila.version;
    });
  }

  async copiaLocal(): Promise<CopiaLocal> {
    const [version, clientes, claves] = await Promise.all([
      this.versionDeCopia(),
      this.clientes(VIGENTES, null),
      this.transaccion.ejecutar(
        (tx) =>
          tx.$queryRaw<{ key_id: string; publica: Uint8Array }[]>`
          SELECT key_id, public_key AS publica FROM tenancy.tenant_signing_keys ORDER BY activated_at`,
      ),
    ]);
    return {
      version,
      clientes,
      claves: claves.map((c) => ({ keyId: c.key_id, publica: new Uint8Array(c.publica) })),
    };
  }

  private clientes(filtro: Prisma.Sql, limite: number | null): Promise<Cliente[]> {
    return this.transaccion.ejecutar(async (tx) =>
      (await tx.$queryRaw<FilaCliente[]>(consultaClientes(filtro, limite))).map(aCliente),
    );
  }
}

function aPersona(fila: FilaPersonaGlobal, clienteId: string | null): PersonaEnVeci {
  return {
    personaId: fila.persona_id,
    nombre: fila.nombre,
    documento: fila.documento,
    cuenta: fila.cuenta,
    clienteId,
  };
}
