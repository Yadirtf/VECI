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
import { RequiereSesion } from '../../../../shared/presentation/http/decoradores/requiere-sesion.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import {
  ConsultarMisTiqueteras,
  ConsultarSaldoDelCliente,
} from '../../application/use-cases/consultar-saldos.use-case';
import { CorregirSaldos } from '../../application/use-cases/corregir.use-case';
import { EstadoDeCuentaResponse, MisTiqueterasResponse } from './saldos.response';
import { AjusteRequest } from './tiqueteras.request';
import { MotivoResponse } from './tipos.response';
import { actorDe } from './ventas.controller';

const UUID = new ParseUUIDPipe();

/** Saldo e historia del cliente en el negocio, y sus ajustes (HU-05-03, HU-05-05). */
@ApiTags('Tiqueteras')
@RequiereComercio()
@Controller('tiqueteras')
export class SaldosController {
  constructor(
    private readonly consultar: ConsultarSaldoDelCliente,
    private readonly corregir: CorregirSaldos,
  ) {}

  @Get('motivos')
  @RequierePermiso('prepaid.adjust_balance')
  @ApiOperation({ operationId: 'listarMotivosDeCorreccion', summary: 'Para anular o ajustar' })
  @ApiOkResponse({ type: MotivoResponse, isArray: true })
  motivos(): Promise<MotivoResponse[]> {
    return this.corregir.motivos();
  }

  @Get('cliente/:clienteId')
  @RequierePermiso('customers.search')
  @ApiOperation({
    operationId: 'consultarSaldoDelCliente',
    summary: 'Saldo por unidad, tiqueteras e historia (HU-05-03)',
  })
  @ApiOkResponse({ type: EstadoDeCuentaResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  saldo(@Param('clienteId', UUID) clienteId: string): Promise<EstadoDeCuentaResponse> {
    return this.consultar.ejecutar(clienteId);
  }

  @Post(':tiqueteraId/ajustes')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('prepaid.adjust_balance')
  @ApiOperation({
    operationId: 'ajustarSaldo',
    summary: 'Suma o quita unidades con motivo; queda en la historia (HU-05-05)',
  })
  @ApiOkResponse({ type: EstadoDeCuentaResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto })
  ajustar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('tiqueteraId', UUID) tiqueteraId: string,
    @Body() ajuste: AjusteRequest,
  ): Promise<EstadoDeCuentaResponse> {
    return this.corregir.ajustar(actorDe(identidad, comercioId), tiqueteraId, ajuste.unidades, {
      motivo: ajuste.motivo,
      nota: ajuste.nota ?? null,
    });
  }
}

/** El cliente ve en su app cuánto le queda en cada negocio (HU-05-02, HU-05-03). */
@ApiTags('Tiqueteras')
@RequiereSesion()
@Controller('mis-tiqueteras')
export class MisTiqueterasController {
  constructor(private readonly misTiqueteras: ConsultarMisTiqueteras) {}

  @Get()
  @ApiOperation({ operationId: 'consultarMisTiqueteras', summary: 'Mi saldo en cada negocio' })
  @ApiOkResponse({ type: MisTiqueterasResponse, isArray: true })
  consultar(@IdentidadActual() identidad: Identidad): Promise<MisTiqueterasResponse[]> {
    return this.misTiqueteras.ejecutar(identidad.usuarioId);
  }
}
