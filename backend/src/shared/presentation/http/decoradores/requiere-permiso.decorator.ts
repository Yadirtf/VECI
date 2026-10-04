import { applyDecorators, SetMetadata } from '@nestjs/common';
import { ApiForbiddenResponse } from '@nestjs/swagger';

export const PERMISOS_REQUERIDOS = 'veci:permisos-requeridos';

/**
 * Permisos (códigos de identity.permissions) que exige la ruta (HU-02-03). Se usa
 * con @RequiereComercio() o @RequierePlataforma(); sin ellos responde 403.
 */
export function RequierePermiso(...codigos: string[]): ClassDecorator & MethodDecorator {
  return applyDecorators(
    SetMetadata(PERMISOS_REQUERIDOS, codigos),
    ApiForbiddenResponse({ description: `Requiere el permiso ${codigos.join(', ')}` }),
  );
}
