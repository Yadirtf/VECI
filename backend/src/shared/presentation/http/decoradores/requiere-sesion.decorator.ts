import { applyDecorators, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiUnauthorizedResponse } from '@nestjs/swagger';
import { SesionGuard } from '../guards/sesion.guard';

/** Ruta de la cuenta propia: exige sesión, no comercio activo. */
export function RequiereSesion(): ClassDecorator & MethodDecorator {
  return applyDecorators(
    UseGuards(SesionGuard),
    ApiBearerAuth(),
    ApiUnauthorizedResponse({ description: 'Sin sesión o sesión cerrada' }),
  );
}
