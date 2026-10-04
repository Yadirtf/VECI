import { CanActivate, ExecutionContext, Inject, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import {
  RESOLVEDOR_IDENTIDAD,
  ResolvedorIdentidad,
} from '../../../application/contexto/resolvedor-identidad.port';
import {
  VERIFICADOR_PLATAFORMA,
  VerificadorPlataforma,
} from '../../../application/contexto/verificador-plataforma.port';
import { PermisoDenegado } from '../../../domain/errores/permiso-denegado.error';
import { PERMISOS_REQUERIDOS } from '../decoradores/requiere-permiso.decorator';
import { autenticar, PeticionAutenticada } from '../peticion-autenticada';

/** Consola interna de VECI: exige sesión y los permisos de un rol de plataforma. */
@Injectable()
export class PlataformaGuard implements CanActivate {
  constructor(
    @Inject(RESOLVEDOR_IDENTIDAD) private readonly identidad: ResolvedorIdentidad,
    @Inject(VERIFICADOR_PLATAFORMA) private readonly plataforma: VerificadorPlataforma,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(contexto: ExecutionContext): Promise<boolean> {
    const peticion = contexto.switchToHttp().getRequest<PeticionAutenticada>();
    const { usuarioId } = await autenticar(peticion, this.identidad);
    const requeridos =
      this.reflector.getAllAndOverride<string[] | undefined>(PERMISOS_REQUERIDOS, [
        contexto.getHandler(),
        contexto.getClass(),
      ]) ?? [];
    const permisos = await this.plataforma.permisosDePlataforma(usuarioId);
    if (permisos.size === 0 || !requeridos.every((permiso) => permisos.has(permiso))) {
      throw new PermisoDenegado('Esta acción es solo para el equipo de VECI.');
    }
    return true;
  }
}
