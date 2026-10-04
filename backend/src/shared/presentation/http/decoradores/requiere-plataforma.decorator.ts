import { applyDecorators, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiUnauthorizedResponse } from '@nestjs/swagger';
import { PlataformaGuard } from '../guards/plataforma.guard';
import { RequierePermiso } from './requiere-permiso.decorator';

/** Ruta de la consola interna de VECI (Administrador o Soporte) con sus permisos. */
export function RequierePlataforma(...permisos: string[]): ClassDecorator & MethodDecorator {
  return applyDecorators(
    UseGuards(PlataformaGuard),
    RequierePermiso(...permisos),
    ApiBearerAuth(),
    ApiUnauthorizedResponse({ description: 'Sin sesión o sesión cerrada' }),
  );
}
