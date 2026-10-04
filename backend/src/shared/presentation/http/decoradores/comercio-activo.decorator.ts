import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { PeticionAutenticada } from '../peticion-autenticada';

/** Id del comercio activo que validó @RequiereComercio(). */
export const ComercioActivo = createParamDecorator(
  (_dato: unknown, contexto: ExecutionContext): string => {
    const comercioId = contexto.switchToHttp().getRequest<PeticionAutenticada>().veciComercioId;
    if (!comercioId) throw new Error('Ruta sin comercio activo: use @RequiereComercio()');
    return comercioId;
  },
);
