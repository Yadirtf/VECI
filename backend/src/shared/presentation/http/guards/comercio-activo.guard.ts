import {
  BadRequestException,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Inject,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { CABECERA_COMERCIO } from '../../../application/contexto/cabeceras';
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
import { PermisoDenegado } from '../../../domain/errores/permiso-denegado.error';
import { PERMISOS_REQUERIDOS } from '../decoradores/requiere-permiso.decorator';
import { autenticar, PeticionAutenticada } from '../peticion-autenticada';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Fija el comercio activo de la petición (HU-01-05): exige la cabecera
 * x-veci-comercio, un usuario autenticado y una membresía activa en ese comercio.
 * Si la ruta pide permisos (@RequierePermiso), los roles vigentes deben darlos
 * (HU-02-03). Es la primera barrera; RLS en PostgreSQL es la segunda (ADR-0002).
 */
@Injectable()
export class ComercioActivoGuard implements CanActivate {
  constructor(
    @Inject(RESOLVEDOR_IDENTIDAD) private readonly identidad: ResolvedorIdentidad,
    @Inject(VERIFICADOR_MEMBRESIA) private readonly membresias: VerificadorMembresia,
    @Inject(ALMACEN_CONTEXTO) private readonly almacen: AlmacenContexto,
    @Inject(OBSERVABILIDAD) private readonly observabilidad: Observabilidad,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(contexto: ExecutionContext): Promise<boolean> {
    const peticion = contexto.switchToHttp().getRequest<PeticionAutenticada>();
    const { usuarioId } = await autenticar(peticion, this.identidad);
    const comercioId = this.leerComercio(peticion).toLowerCase();
    if (!(await this.membresias.esMiembroActivo(usuarioId, comercioId))) {
      throw new ForbiddenException('No tienes acceso a este negocio.');
    }
    await this.exigirPermisos(contexto, usuarioId, comercioId);
    this.almacen.fijarComercio({ comercioId, usuarioId });
    peticion.veciComercioId = comercioId;
    this.observabilidad.etiquetarComercio(comercioId);
    return true;
  }

  private async exigirPermisos(
    contexto: ExecutionContext,
    usuarioId: string,
    comercioId: string,
  ): Promise<void> {
    const requeridos = this.reflector.getAllAndOverride<string[] | undefined>(PERMISOS_REQUERIDOS, [
      contexto.getHandler(),
      contexto.getClass(),
    ]);
    if (!requeridos?.length) return;
    const permisos = await this.membresias.permisosEn(usuarioId, comercioId);
    if (!requeridos.every((permiso) => permisos.has(permiso))) throw new PermisoDenegado();
  }

  private leerComercio(peticion: PeticionAutenticada): string {
    const valor = peticion.headers[CABECERA_COMERCIO];
    if (typeof valor !== 'string' || !UUID.test(valor)) {
      throw new BadRequestException(
        `Falta la cabecera ${CABECERA_COMERCIO} con el negocio activo.`,
      );
    }
    return valor;
  }
}
