import { Module } from '@nestjs/common';
import { AUDITORIA, Auditoria } from '../../shared/application/puertos/auditoria.port';
import { AutenticacionModule, EmitirPinTemporal } from '../autenticacion';
import {
  DISPOSITIVOS_REPOSITORY,
  DispositivosRepository,
} from './application/puertos/dispositivos.repository';
import { PERSONAL_REPOSITORY, PersonalRepository } from './application/puertos/personal.repository';
import { CambiarEstadoCajero } from './application/use-cases/cambiar-estado-cajero.use-case';
import { CerrarSesionDispositivo } from './application/use-cases/cerrar-sesion-dispositivo.use-case';
import { InvitarCajero } from './application/use-cases/invitar-cajero.use-case';
import { ListarDispositivos } from './application/use-cases/listar-dispositivos.use-case';
import { ListarPersonal } from './application/use-cases/listar-personal.use-case';
import { RestablecerPinCajero } from './application/use-cases/restablecer-pin-cajero.use-case';
import { PrismaDispositivosRepository } from './infrastructure/persistence/prisma-dispositivos.repository';
import { PrismaPersonalRepository } from './infrastructure/persistence/prisma-personal.repository';
import { DispositivosController } from './presentation/http/dispositivos.controller';
import { PersonalController } from './presentation/http/personal.controller';

/** EP-02 · El propietario gestiona su equipo y los celulares de la caja (HU-02-04 a HU-02-06). */
@Module({
  imports: [AutenticacionModule],
  controllers: [PersonalController, DispositivosController],
  providers: [
    { provide: PERSONAL_REPOSITORY, useClass: PrismaPersonalRepository },
    { provide: DISPOSITIVOS_REPOSITORY, useClass: PrismaDispositivosRepository },
    {
      provide: ListarPersonal,
      useFactory: (personal: PersonalRepository) => new ListarPersonal(personal),
      inject: [PERSONAL_REPOSITORY],
    },
    {
      provide: InvitarCajero,
      useFactory: (
        personal: PersonalRepository,
        pinTemporal: EmitirPinTemporal,
        auditoria: Auditoria,
      ) => new InvitarCajero({ personal, pinTemporal, auditoria }),
      inject: [PERSONAL_REPOSITORY, EmitirPinTemporal, AUDITORIA],
    },
    {
      provide: CambiarEstadoCajero,
      useFactory: (personal: PersonalRepository, auditoria: Auditoria) =>
        new CambiarEstadoCajero(personal, auditoria),
      inject: [PERSONAL_REPOSITORY, AUDITORIA],
    },
    {
      provide: RestablecerPinCajero,
      useFactory: (personal: PersonalRepository, pinTemporal: EmitirPinTemporal) =>
        new RestablecerPinCajero(personal, pinTemporal),
      inject: [PERSONAL_REPOSITORY, EmitirPinTemporal],
    },
    {
      provide: ListarDispositivos,
      useFactory: (dispositivos: DispositivosRepository) => new ListarDispositivos(dispositivos),
      inject: [DISPOSITIVOS_REPOSITORY],
    },
    {
      provide: CerrarSesionDispositivo,
      useFactory: (dispositivos: DispositivosRepository, auditoria: Auditoria) =>
        new CerrarSesionDispositivo(dispositivos, auditoria),
      inject: [DISPOSITIVOS_REPOSITORY, AUDITORIA],
    },
  ],
  exports: [InvitarCajero],
})
export class PersonalModule {}
