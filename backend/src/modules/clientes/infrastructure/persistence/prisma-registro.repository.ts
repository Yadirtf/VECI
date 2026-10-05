import { Inject, Injectable } from '@nestjs/common';
import {
  GENERADOR_IDS,
  GeneradorIds,
} from '../../../../shared/application/puertos/generador-ids.port';
import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';
import { ClienteTransaccion } from '../../../../shared/infrastructure/prisma/transaccion-comercio';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { EstadoCuenta } from '../../domain/entities/cliente';
import { YaTieneCuenta } from '../../domain/errors/errores-clientes';
import {
  RegistroPropio,
  RegistroRepository,
  TipoDeDocumento,
} from '../../application/puertos/registro.repository';
import {
  codigoPostgres,
  crearPersona,
  crearUsuario,
  emitirQrPersonal,
  registrarConsentimiento,
  VIOLACION_UNICA,
} from './alta-de-persona';
import {
  consultaCuentaPorCelular,
  consultaPersonaPorDocumento,
  FilaPersonaGlobal,
} from './consultas-cuenta';

/**
 * Auto-registro (HU-04-01), fuera de cualquier comercio. people y person_contacts
 * aceptan altas sin contexto (register_people); el resto no tiene RLS.
 */
@Injectable()
export class PrismaRegistroRepository implements RegistroRepository {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(GENERADOR_IDS) private readonly ids: GeneradorIds,
  ) {}

  tiposDeDocumento(): Promise<TipoDeDocumento[]> {
    return this.prisma.$queryRaw<TipoDeDocumento[]>`
      SELECT code AS codigo, name AS nombre, validation_regex AS patron
        FROM core.document_types
       WHERE for_natural_person AND is_active
       ORDER BY sort_order, id`;
  }

  async cuentaPorCelular(celular: string): Promise<'ACTIVA' | 'PENDIENTE' | null> {
    const [fila] = await this.prisma.$queryRaw<{ cuenta: 'ACTIVA' | 'PENDIENTE' }[]>(
      consultaCuentaPorCelular(celular),
    );
    return fila?.cuenta ?? null;
  }

  async cuentaPorDocumento(tipo: string, numero: string): Promise<EstadoCuenta | null> {
    const [fila] = await this.prisma.$queryRaw<FilaPersonaGlobal[]>(
      consultaPersonaPorDocumento(tipo, numero),
    );
    return fila?.cuenta ?? null;
  }

  async registrar(registro: RegistroPropio): Promise<{ usuarioId: string; personaId: string }> {
    const personaId = this.ids.siguiente();
    const usuarioId = this.ids.siguiente();
    try {
      await this.prisma.$transaction((tx) => this.alta(tx, registro, { personaId, usuarioId }));
    } catch (error) {
      if (error instanceof ErrorDeDominio) throw error;
      // Otra persona se registró con el mismo dato en el mismo instante.
      if (codigoPostgres(error) === VIOLACION_UNICA) throw new YaTieneCuenta('celular');
      throw error;
    }
    return { usuarioId, personaId };
  }

  private async alta(
    tx: ClienteTransaccion,
    registro: RegistroPropio,
    ids: { personaId: string; usuarioId: string },
  ): Promise<void> {
    const { personaId, usuarioId } = ids;
    await crearPersona(tx, registro, personaId);
    await crearUsuario(tx, { usuarioId, personaId, celular: registro.celular, activo: true });
    await tx.$executeRaw`
      INSERT INTO identity.user_credentials (user_id, credential_type_id, secret_hash, must_change)
      SELECT ${usuarioId}::uuid, ct.id, ${registro.hashPin}, false
        FROM identity.credential_types ct WHERE ct.code = 'PIN'`;
    await registrarConsentimiento(tx, {
      personaId,
      politicaVersionId: registro.politicaVersionId,
      canal: 'SELF_APP',
      ip: registro.ip,
      porComercio: false,
      actorUsuarioId: null,
    });
    await emitirQrPersonal(tx, personaId);
  }
}
