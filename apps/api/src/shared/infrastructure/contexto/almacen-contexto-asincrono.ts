import { AsyncLocalStorage } from 'node:async_hooks';
import { AlmacenContexto } from '../../application/contexto/almacen-contexto.port';
import { ContextoComercio } from '../../application/contexto/contexto-comercio';

interface EstadoPeticion {
  comercio: ContextoComercio | null;
}

/** Contexto por petición con AsyncLocalStorage: cada petición ve solo el suyo. */
export class AlmacenContextoAsincrono implements AlmacenContexto {
  private readonly almacen = new AsyncLocalStorage<EstadoPeticion>();

  ejecutar<T>(trabajo: () => T): T {
    return this.almacen.run({ comercio: null }, trabajo);
  }

  fijarComercio(contexto: ContextoComercio): void {
    const estado = this.almacen.getStore();
    if (!estado) {
      throw new Error('El contexto de la petición no se inició (falta el middleware)');
    }
    estado.comercio = contexto;
  }

  comercioActual(): ContextoComercio | null {
    return this.almacen.getStore()?.comercio ?? null;
  }
}
