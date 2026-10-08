import {
  Body,
  Controller,
  Get,
  Headers,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Res,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { ComercioActivo } from '../../../../shared/presentation/http/decoradores/comercio-activo.decorator';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import {
  ConsultarCatalogoDeVenta,
  GestionarTipos,
} from '../../application/use-cases/tipos.use-case';
import { EstadoTipoRequest, TipoRequest } from './tiqueteras.request';
import { CatalogoDeVentaResponse, TipoResponse, UnidadResponse } from './tipos.response';

const UUID = new ParseUUIDPipe();

/** La pizarra de tiqueteras del negocio (HU-05-01). */
@ApiTags('Tiqueteras')
@RequiereComercio()
@RequierePermiso('prepaid.manage_package_types')
@Controller('tiqueteras')
export class TiposController {
  constructor(private readonly tipos: GestionarTipos) {}

  @Get('tipos')
  @ApiOperation({ operationId: 'listarTiposDeTiquetera', summary: 'Activos y guardados' })
  @ApiOkResponse({ type: TipoResponse, isArray: true })
  listar(): Promise<TipoResponse[]> {
    return this.tipos.listar();
  }

  @Get('unidades')
  @ApiOperation({ operationId: 'listarUnidadesDeConsumo', summary: 'Almuerzo, desayuno, café…' })
  @ApiOkResponse({ type: UnidadResponse, isArray: true })
  unidades(): Promise<UnidadResponse[]> {
    return this.tipos.unidades();
  }

  @Post('tipos')
  @ApiOperation({ operationId: 'crearTipoDeTiquetera', summary: 'Nuevo paquete (HU-05-01)' })
  @ApiCreatedResponse({ type: TipoResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya hay uno con ese nombre' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto })
  crear(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Body() datos: TipoRequest,
  ): Promise<TipoResponse> {
    const actor = { usuarioId: identidad.usuarioId, comercioId, dispositivoId: null };
    return this.tipos.crear(actor, datos);
  }

  @Patch('tipos/:tipoId')
  @ApiOperation({
    operationId: 'editarTipoDeTiquetera',
    summary: 'Cambia precio o vigencia; lo vendido no cambia',
  })
  @ApiOkResponse({ type: TipoResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Cantidad de uno ya vendido' })
  editar(@Param('tipoId', UUID) tipoId: string, @Body() datos: TipoRequest): Promise<TipoResponse> {
    return this.tipos.editar(tipoId, datos);
  }

  @Patch('tipos/:tipoId/estado')
  @ApiOperation({ operationId: 'cambiarEstadoDeTipo', summary: 'Activar o desactivar la venta' })
  @ApiOkResponse({ type: TipoResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  cambiarEstado(
    @Param('tipoId', UUID) tipoId: string,
    @Body() cambio: EstadoTipoRequest,
  ): Promise<TipoResponse> {
    return this.tipos.cambiarEstado(tipoId, cambio.activo);
  }
}

/** Lo que la caja guarda para vender sin internet (HU-05-02, ADR-0004). */
@ApiTags('Ventas')
@RequiereComercio()
@RequierePermiso('prepaid.sell')
@Controller('ventas')
export class CatalogoController {
  constructor(private readonly catalogo: ConsultarCatalogoDeVenta) {}

  @Get('catalogo')
  @ApiOperation({
    operationId: 'bajarCatalogoDeVenta',
    summary: 'Tipos activos y medios de pago; 304 si no cambió',
  })
  @ApiOkResponse({ type: CatalogoDeVentaResponse })
  @ApiResponse({ status: HttpStatus.NOT_MODIFIED, description: 'La copia del celular está al día' })
  async bajar(
    @Headers('if-none-match') etag: string | undefined,
    @Res({ passthrough: true }) respuesta: Response,
  ): Promise<CatalogoDeVentaResponse | undefined> {
    const actual = `"${await this.catalogo.version()}"`;
    respuesta.setHeader('ETag', actual);
    if (etag === actual) {
      respuesta.status(HttpStatus.NOT_MODIFIED);
      return undefined;
    }
    const catalogo = await this.catalogo.catalogo();
    respuesta.setHeader('ETag', `"${catalogo.version}"`);
    return {
      ...catalogo,
      medios: catalogo.medios.map((m) => ({ ...m, canales: [...m.canales] })),
    };
  }
}
