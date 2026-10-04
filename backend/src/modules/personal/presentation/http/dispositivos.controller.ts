import { Controller, Get, HttpCode, HttpStatus, Param, ParseUUIDPipe, Post } from '@nestjs/common';
import { ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { ComercioActivo } from '../../../../shared/presentation/http/decoradores/comercio-activo.decorator';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { CerrarSesionDispositivo } from '../../application/use-cases/cerrar-sesion-dispositivo.use-case';
import { ListarDispositivos } from '../../application/use-cases/listar-dispositivos.use-case';
import { CierreRemotoResponse, DispositivoResponse } from './personal.response';

@ApiTags('Equipo del negocio')
@RequiereComercio()
@RequierePermiso('tenancy.revoke_devices')
@Controller('dispositivos')
export class DispositivosController {
  constructor(
    private readonly listarDispositivos: ListarDispositivos,
    private readonly cerrarSesion: CerrarSesionDispositivo,
  ) {}

  @Get()
  @ApiOperation({
    operationId: 'listarDispositivos',
    summary: 'Celulares de la caja y sus sesiones',
  })
  @ApiOkResponse({ type: DispositivoResponse, isArray: true })
  listar(): Promise<DispositivoResponse[]> {
    return this.listarDispositivos.ejecutar();
  }

  @Post(':dispositivoId/cerrar-sesion')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ operationId: 'cerrarSesionDispositivo', summary: 'Cierre remoto (HU-02-06)' })
  @ApiOkResponse({ type: CierreRemotoResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  cerrar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('dispositivoId', new ParseUUIDPipe()) dispositivoId: string,
  ): Promise<CierreRemotoResponse> {
    return this.cerrarSesion.ejecutar(
      { usuarioId: identidad.usuarioId, comercioId },
      dispositivoId,
    );
  }
}
