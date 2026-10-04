import { applyDecorators, UseGuards } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiForbiddenResponse,
  ApiHeader,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import {
  CABECERA_COMERCIO,
  CABECERA_USUARIO_DESARROLLO,
} from '../../../application/contexto/cabeceras';
import { ComercioActivoGuard } from '../guards/comercio-activo.guard';

/** Marca un controlador o ruta como operación dentro de un comercio (HU-01-05). */
export function RequiereComercio(): ClassDecorator & MethodDecorator {
  return applyDecorators(
    UseGuards(ComercioActivoGuard),
    ApiHeader({ name: CABECERA_COMERCIO, required: true, description: 'Id del negocio activo' }),
    ApiHeader({
      name: CABECERA_USUARIO_DESARROLLO,
      required: false,
      description: 'Solo desarrollo y staging, hasta EP-02: id del usuario',
    }),
    ApiBadRequestResponse({ description: 'Falta el negocio activo' }),
    ApiUnauthorizedResponse({ description: 'Sin sesión' }),
    ApiForbiddenResponse({ description: 'El usuario no trabaja en ese negocio' }),
  );
}
