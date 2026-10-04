import { CanActivate, ExecutionContext, Inject, Injectable } from '@nestjs/common';
import {
  RESOLVEDOR_IDENTIDAD,
  ResolvedorIdentidad,
} from '../../../application/contexto/resolvedor-identidad.port';
import { autenticar, PeticionAutenticada } from '../peticion-autenticada';

/** Rutas de la cuenta propia: solo exigen una sesión válida, sin comercio activo. */
@Injectable()
export class SesionGuard implements CanActivate {
  constructor(@Inject(RESOLVEDOR_IDENTIDAD) private readonly identidad: ResolvedorIdentidad) {}

  async canActivate(contexto: ExecutionContext): Promise<boolean> {
    await autenticar(contexto.switchToHttp().getRequest<PeticionAutenticada>(), this.identidad);
    return true;
  }
}
