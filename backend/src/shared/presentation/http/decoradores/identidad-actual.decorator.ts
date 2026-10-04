import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Identidad } from '../../../application/contexto/identidad';
import { PeticionAutenticada } from '../peticion-autenticada';

/** Identidad que dejó el guard de sesión, comercio o plataforma. */
export const IdentidadActual = createParamDecorator(
  (_dato: unknown, contexto: ExecutionContext): Identidad => {
    const identidad = contexto.switchToHttp().getRequest<PeticionAutenticada>().veciIdentidad;
    if (!identidad) throw new Error('Ruta sin guard de sesión: use @RequiereSesion()');
    return identidad;
  },
);
