import { Inject, Injectable, NestMiddleware } from '@nestjs/common';
import {
  ALMACEN_CONTEXTO,
  AlmacenContexto,
} from '../../../application/contexto/almacen-contexto.port';

/** Abre un contexto vacío por petición; el guard de comercio lo completa. */
@Injectable()
export class ContextoPeticionMiddleware implements NestMiddleware {
  constructor(@Inject(ALMACEN_CONTEXTO) private readonly almacen: AlmacenContexto) {}

  use(_peticion: unknown, _respuesta: unknown, siguiente: () => void): void {
    this.almacen.ejecutar(siguiente);
  }
}
