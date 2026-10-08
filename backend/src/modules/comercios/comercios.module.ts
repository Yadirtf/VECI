import { Module } from '@nestjs/common';
import {
  ALMACEN_CONTEXTO,
  AlmacenContexto,
} from '../../shared/application/contexto/almacen-contexto.port';
import { AUDITORIA, Auditoria } from '../../shared/application/puertos/auditoria.port';
import { GENERADOR_IDS, GeneradorIds } from '../../shared/application/puertos/generador-ids.port';
import { InvitarCajero, PersonalModule } from '../personal';
import {
  COMERCIOS_REPOSITORY,
  ComerciosRepository,
} from './application/puertos/comercios.repository';
import { CatalogosDeComercio } from './application/use-cases/catalogos.use-case';
import { PerfilDelComercio } from './application/use-cases/perfil-comercio.use-case';
import { RegistrarComercio } from './application/use-cases/registrar-comercio.use-case';
import { RegistrarComercioParaPropietario } from './application/use-cases/registrar-para-propietario.use-case';
import { RevisarSolicitudes } from './application/use-cases/revisar-solicitudes.use-case';
import { SolicitarRegistroDeNegocio } from './application/use-cases/solicitar-registro.use-case';
import {
  SOLICITUDES_REPOSITORY,
  SolicitudesRepository,
} from './application/puertos/solicitudes.repository';
import { PrismaComerciosRepository } from './infrastructure/persistence/prisma-comercios.repository';
import { PrismaSolicitudesRepository } from './infrastructure/persistence/prisma-solicitudes.repository';
import { ComerciosController } from './presentation/http/comercios.controller';
import { SolicitudesController } from './presentation/http/solicitudes.controller';

/**
 * EP-03 · Alta de negocios, sus datos y el camino para abrir (HU-03-01). Registrar
 * un negocio propio es una solicitud que aprueba Administración VECI (ADR-0019).
 */
@Module({
  imports: [PersonalModule],
  controllers: [ComerciosController, SolicitudesController],
  providers: [
    { provide: COMERCIOS_REPOSITORY, useClass: PrismaComerciosRepository },
    { provide: SOLICITUDES_REPOSITORY, useClass: PrismaSolicitudesRepository },
    {
      provide: CatalogosDeComercio,
      useFactory: (comercios: ComerciosRepository) => new CatalogosDeComercio(comercios),
      inject: [COMERCIOS_REPOSITORY],
    },
    {
      provide: PerfilDelComercio,
      useFactory: (comercios: ComerciosRepository) => new PerfilDelComercio(comercios),
      inject: [COMERCIOS_REPOSITORY],
    },
    {
      provide: RegistrarComercio,
      useFactory: (comercios: ComerciosRepository, ids: GeneradorIds, auditoria: Auditoria) =>
        new RegistrarComercio({ comercios, ids, auditoria }),
      inject: [COMERCIOS_REPOSITORY, GENERADOR_IDS, AUDITORIA],
    },
    {
      provide: RegistrarComercioParaPropietario,
      useFactory: (
        registrar: RegistrarComercio,
        invitar: InvitarCajero,
        almacen: AlmacenContexto,
      ) => new RegistrarComercioParaPropietario({ registrar, invitar, almacen }),
      inject: [RegistrarComercio, InvitarCajero, ALMACEN_CONTEXTO],
    },
    {
      provide: SolicitarRegistroDeNegocio,
      useFactory: (
        solicitudes: SolicitudesRepository,
        registrar: RegistrarComercio,
        ids: GeneradorIds,
        auditoria: Auditoria,
      ) => new SolicitarRegistroDeNegocio({ solicitudes, registrar, ids, auditoria }),
      inject: [SOLICITUDES_REPOSITORY, RegistrarComercio, GENERADOR_IDS, AUDITORIA],
    },
    {
      provide: RevisarSolicitudes,
      useFactory: (
        solicitudes: SolicitudesRepository,
        registrar: RegistrarComercio,
        auditoria: Auditoria,
      ) => new RevisarSolicitudes({ solicitudes, registrar, auditoria }),
      inject: [SOLICITUDES_REPOSITORY, RegistrarComercio, AUDITORIA],
    },
  ],
})
export class ComerciosModule {}
