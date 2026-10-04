import { Module } from '@nestjs/common';
import { SentryModule } from '@sentry/nestjs/setup';
import { HorariosModule } from './modules/horarios';
import { SaludModule } from './modules/salud';
import { SharedModule } from './shared/shared.module';

@Module({
  imports: [SentryModule.forRoot(), SharedModule, SaludModule, HorariosModule],
})
export class AppModule {}
