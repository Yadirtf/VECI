import { Controller, Get, Header } from '@nestjs/common';
import { EmitirHojaDePruebaUseCase } from '../../application/use-cases/emitir-hoja-de-prueba.use-case';
import {
  DatosOffline,
  ObtenerDatosOfflineUseCase,
} from '../../application/use-cases/obtener-datos-offline.use-case';
import { renderHojaDePrueba } from './hoja-de-prueba.page';

@Controller('poc')
export class QrController {
  constructor(
    private readonly emitirHoja: EmitirHojaDePruebaUseCase,
    private readonly obtenerDatosOffline: ObtenerDatosOfflineUseCase,
  ) {}

  /** Hoja imprimible con QR válidos, revocado, de otro comercio y alterado. */
  @Get('qr-de-prueba')
  @Header('Content-Type', 'text/html; charset=utf-8')
  hojaDePrueba(): Promise<string> {
    return renderHojaDePrueba(this.emitirHoja.execute());
  }

  /** Mismos tokens en JSON, para pruebas automáticas. */
  @Get('qr-de-prueba.json')
  hojaDePruebaJson() {
    return this.emitirHoja.execute();
  }

  @Get('datos-offline')
  datosOffline(): DatosOffline {
    this.emitirHoja.execute();
    return this.obtenerDatosOffline.execute();
  }
}
