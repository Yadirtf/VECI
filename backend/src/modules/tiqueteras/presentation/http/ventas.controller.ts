import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { ComercioActivo } from '../../../../shared/presentation/http/decoradores/comercio-activo.decorator';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { Actor } from '../../application/dto/tiqueteras.dto';
import { CorregirSaldos } from '../../application/use-cases/corregir.use-case';
import { VenderTiquetera } from '../../application/use-cases/vender.use-case';
import { EstadoDeCuentaResponse, VentaResponse, VentaResumenResponse } from './saldos.response';
import { CorreccionRequest, VentaRequest } from './tiqueteras.request';

export const actorDe = (identidad: Identidad, comercioId: string): Actor => ({
  usuarioId: identidad.usuarioId,
  comercioId,
  dispositivoId: identidad.dispositivoId,
});

/** Vender una tiquetera y, si hubo un error, anular la venta (HU-05-02, HU-05-05). */
@ApiTags('Ventas')
@RequiereComercio()
@Controller('ventas')
export class VentasController {
  constructor(
    private readonly vender: VenderTiquetera,
    private readonly corregir: CorregirSaldos,
  ) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('prepaid.sell')
  @ApiOperation({
    operationId: 'venderTiquetera',
    summary: 'Carga el saldo de inmediato; reenviarla no la duplica (HU-05-02)',
  })
  @ApiOkResponse({ type: VentaResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto, description: 'Tipo o cliente no existe' })
  @ApiConflictResponse({
    type: RespuestaErrorDto,
    description: 'El precio cambió, el tipo no se vende o el id es de otra venta',
  })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto })
  registrar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Body() venta: VentaRequest,
  ): Promise<VentaResponse> {
    return this.vender.ejecutar(actorDe(identidad, comercioId), {
      ventaId: venta.ventaId,
      clienteId: venta.clienteId,
      tipoId: venta.tipoId,
      precio: venta.precio,
      pago: {
        medio: venta.pago.medio,
        canal: venta.pago.canal ?? null,
        referencia: venta.pago.referencia?.trim() || null,
      },
      ocurridaEn: venta.ocurridaEn ?? null,
      sinConexion: venta.sinConexion ?? false,
    });
  }

  @Get()
  @RequierePermiso('prepaid.void_sale')
  @ApiOperation({ operationId: 'listarVentasRecientes', summary: 'Las últimas 50 ventas' })
  @ApiOkResponse({ type: VentaResumenResponse, isArray: true })
  recientes(): Promise<VentaResumenResponse[]> {
    return this.corregir.ventasRecientes();
  }

  @Post(':ventaId/anulacion')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('prepaid.void_sale')
  @ApiOperation({
    operationId: 'anularVenta',
    summary: 'Reversa la venta con motivo; nada se borra (HU-05-05)',
  })
  @ApiOkResponse({ type: EstadoDeCuentaResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya estaba anulada' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Falta el motivo' })
  anular(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('ventaId', ParseUUIDPipe) ventaId: string,
    @Body() correccion: CorreccionRequest,
  ): Promise<EstadoDeCuentaResponse> {
    return this.corregir.anular(actorDe(identidad, comercioId), ventaId, {
      motivo: correccion.motivo,
      nota: correccion.nota ?? null,
    });
  }
}
