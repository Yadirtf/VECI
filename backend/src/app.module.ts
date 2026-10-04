import { Module } from '@nestjs/common';
import { SentryModule } from '@sentry/nestjs/setup';
import { AutenticacionModule } from './modules/autenticacion';
import { HorariosModule } from './modules/horarios';
import { PersonalModule } from './modules/personal';
import { SaludModule } from './modules/salud';
import { SoporteModule } from './modules/soporte';
import { SharedModule } from './shared/shared.module';

@Module({
  imports: [
    SentryModule.forRoot(),
    SharedModule,
    SaludModule,
    AutenticacionModule,
    HorariosModule,
    PersonalModule,
    SoporteModule,
  ],
})
export class AppModule {}
