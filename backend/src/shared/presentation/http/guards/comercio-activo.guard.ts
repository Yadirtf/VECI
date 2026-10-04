import {
  BadRequestException,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { CABECERA_COMERCIO } from '../../../application/contexto/cabeceras';
import type { Request } from 'express';
import {
  ALMACEN_CONTEXTO,
  AlmacenContexto,
} from '../../../application/contexto/almacen-contexto.port';
import {
  RESOLVEDOR_IDENTIDAD,
  ResolvedorIdentidad,
} from '../../../application/contexto/resolvedor-identidad.port';
import {
  VERIFICADOR_MEMBRESIA,
  VerificadorMembresia,
} from '../../../application/contexto/verificador-membresia.port';
import { OBSERVABILIDAD, Observabilidad } from '../../../application/puertos/observabilidad.port';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Fija el comercio activo de la petición (HU-01-05): exige la cabecera
 * x-veci-comercio, un usuario autenticado y una membresía activa en ese comercio.
 * Es la primera barrera; RLS en PostgreSQL es la segunda (ADR-0002).
 */
@Injectable()
export class ComercioActivoGuard implements CanActivate {
  constructor(
    @Inject(RESOLVEDOR_IDENTIDAD) private readonly identidad: ResolvedorIdentidad,
    @Inject(VERIFICADOR_MEMBRESIA) private readonly membresias: VerificadorMembresia,
    @Inject(ALMACEN_CONTEXTO) private readonly almacen: AlmacenContexto,
    @Inject(OBSERVABILIDAD) private readonly observabilidad: Observabilidad,
  ) {}

  async canActivate(contexto: ExecutionContext): Promise<boolean> {
    const peticion = contexto.switchToHttp().getRequest<Request>();
    const usuarioId = await this.identidad.resolver(peticion.headers);
    if (!usuarioId) {
      throw new UnauthorizedException('Primero inicia sesión, veci.');
    }
    const comercioId = this.leerComercio(peticion);
    if (!(await this.membresias.esMiembroActivo(usuarioId, comercioId))) {
      throw new ForbiddenException('No tienes acceso a este negocio.');
    }
    this.almacen.fijarComercio({ comercioId: comercioId.toLowerCase(), usuarioId });
    this.observabilidad.etiquetarComercio(comercioId);
    return true;
  }

  private leerComercio(peticion: Request): string {
    const valor = peticion.headers[CABECERA_COMERCIO];
    if (typeof valor !== 'string' || !UUID.test(valor)) {
      throw new BadRequestException(
        `Falta la cabecera ${CABECERA_COMERCIO} con el negocio activo.`,
      );
    }
    return valor;
  }
}
