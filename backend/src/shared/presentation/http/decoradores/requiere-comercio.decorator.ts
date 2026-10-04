import { applyDecorators, UseGuards } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiHeader,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CABECERA_COMERCIO } from '../../../application/contexto/cabeceras';
import { ComercioActivoGuard } from '../guards/comercio-activo.guard';

/** Marca un controlador o ruta como operación dentro de un comercio (HU-01-05). */
export function RequiereComercio(): ClassDecorator & MethodDecorator {
  return applyDecorators(
    UseGuards(ComercioActivoGuard),
    ApiBearerAuth(),
    ApiHeader({ name: CABECERA_COMERCIO, required: true, description: 'Id del negocio activo' }),
    ApiBadRequestResponse({ description: 'Falta el negocio activo' }),
    ApiUnauthorizedResponse({ description: 'Sin sesión o sesión cerrada' }),
    ApiForbiddenResponse({
      description: 'El usuario no trabaja en ese negocio o su rol no alcanza',
    }),
  );
}
