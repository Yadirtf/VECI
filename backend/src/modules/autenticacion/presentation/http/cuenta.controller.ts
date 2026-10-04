import { Body, Controller, Get, HttpCode, HttpStatus, Post, Put } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiForbiddenResponse,
  ApiNoContentResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereSesion } from '../../../../shared/presentation/http/decoradores/requiere-sesion.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { ActivarComercio } from '../../application/use-cases/activar-comercio.use-case';
import { CambiarPin } from '../../application/use-cases/cambiar-pin.use-case';
import { ConsultarEspacios } from '../../application/use-cases/consultar-espacios.use-case';
import { DefinirCorreoYContrasena } from '../../application/use-cases/definir-correo-y-contrasena.use-case';
import {
  CambiarPinRequest,
  ComercioActivoRequest,
  CorreoYContrasenaRequest,
} from './cuenta.request';
import { ComercioActivoResponse, CorreoResponse, EspacioResponse } from './sesion.response';

@ApiTags('Mi cuenta')
@RequiereSesion()
@Controller('cuenta')
export class CuentaController {
  constructor(
    private readonly consultar: ConsultarEspacios,
    private readonly activar: ActivarComercio,
    private readonly cambiarPin: CambiarPin,
    private readonly definirCorreo: DefinirCorreoYContrasena,
  ) {}

  @Get('espacios')
  @ApiOperation({
    operationId: 'listarMisEspacios',
    summary: 'Comercios donde trabajo o soy cliente',
  })
  @ApiOkResponse({ type: EspacioResponse, isArray: true })
  espacios(@IdentidadActual() identidad: Identidad): Promise<EspacioResponse[]> {
    return this.consultar.deUsuario(identidad.usuarioId);
  }

  @Post('comercio-activo')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ operationId: 'elegirComercio', summary: 'Elige el negocio con el que trabajo' })
  @ApiOkResponse({ type: ComercioActivoResponse })
  @ApiForbiddenResponse({ type: RespuestaErrorDto, description: 'No es uno de mis negocios' })
  elegir(
    @IdentidadActual() identidad: Identidad,
    @Body() solicitud: ComercioActivoRequest,
  ): Promise<ComercioActivoResponse> {
    return this.activar.ejecutar(identidad, solicitud.comercioId);
  }

  @Put('pin')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ operationId: 'cambiarMiPin', summary: 'Cambia mi PIN' })
  @ApiNoContentResponse()
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'PIN débil' })
  cambiar(@IdentidadActual() identidad: Identidad, @Body() s: CambiarPinRequest): Promise<void> {
    return this.cambiarPin.ejecutar({ identidad, ...s });
  }

  @Put('correo-y-contrasena')
  @ApiOperation({
    operationId: 'definirCorreoYContrasena',
    summary: 'Correo y contraseña para entrar al panel (HU-02-02)',
  })
  @ApiOkResponse({ type: CorreoResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'El correo es de otra cuenta' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Contraseña débil' })
  correo(
    @IdentidadActual() identidad: Identidad,
    @Body() s: CorreoYContrasenaRequest,
  ): Promise<CorreoResponse> {
    return this.definirCorreo.ejecutar({ identidad, ...s });
  }
}
