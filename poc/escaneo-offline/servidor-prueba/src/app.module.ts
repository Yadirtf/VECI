import { Module } from '@nestjs/common';
import { QrModule } from './modules/qr/qr.module';
import { SincronizacionModule } from './modules/sincronizacion/sincronizacion.module';

@Module({ imports: [QrModule, SincronizacionModule] })
export class AppModule {}
