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
import { PrismaComerciosRepository } from './infrastructure/persistence/prisma-comercios.repository';
import { ComerciosController } from './presentation/http/comercios.controller';

/** EP-03 · Alta de negocios, sus datos y el camino para abrir (HU-03-01). */
@Module({
  imports: [PersonalModule],
  controllers: [ComerciosController],
  providers: [
    { provide: COMERCIOS_REPOSITORY, useClass: PrismaComerciosRepository },
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
  ],
})
export class ComerciosModule {}
