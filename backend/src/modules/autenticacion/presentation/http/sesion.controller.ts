import { Body, Controller, HttpCode, HttpStatus, Ip, Post } from '@nestjs/common';
import {
  ApiForbiddenResponse,
  ApiNoContentResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereSesion } from '../../../../shared/presentation/http/decoradores/requiere-sesion.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { ResultadoIngreso } from '../../application/dto/sesion.output';
import { CerrarSesion } from '../../application/use-cases/cerrar-sesion.use-case';
import { DefinirPinNuevo } from '../../application/use-cases/definir-pin-nuevo.use-case';
import { IniciarSesion } from '../../application/use-cases/iniciar-sesion.use-case';
import { RenovarSesion } from '../../application/use-cases/renovar-sesion.use-case';
import {
  IngresoConContrasenaRequest,
  IngresoConPinRequest,
  PinNuevoRequest,
  RenovarSesionRequest,
} from './ingreso.request';
import { IngresoResponse, SesionResponse } from './sesion.response';

function aRespuesta(resultado: ResultadoIngreso): IngresoResponse {
  if (resultado.tipo === 'CAMBIO_DE_PIN') {
    const { tokenCambio, nombre } = resultado;
    return { requiereCambioDePin: true, tokenCambio, nombre };
  }
  const { sesion } = resultado;
  return { requiereCambioDePin: false, nombre: sesion.usuario.nombre, sesion };
}

@ApiTags('Sesión')
@Controller('sesion')
export class SesionController {
  constructor(
    private readonly iniciar: IniciarSesion,
    private readonly definirPin: DefinirPinNuevo,
    private readonly renovar: RenovarSesion,
    private readonly cerrar: CerrarSesion,
  ) {}

  @Post('con-pin')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ operationId: 'entrarConPin', summary: 'Entra con celular y PIN (HU-02-01)' })
  @ApiOkResponse({ type: IngresoResponse })
  @ApiUnauthorizedResponse({ type: RespuestaErrorDto, description: 'No coinciden o bloqueada' })
  @ApiForbiddenResponse({ type: RespuestaErrorDto, description: 'Cuenta pausada por VECI' })
  async conPin(@Body() s: IngresoConPinRequest, @Ip() ip: string): Promise<IngresoResponse> {
    const entrada = { via: 'PIN' as const, identificador: s.celular, secreto: s.pin };
    return aRespuesta(await this.iniciar.ejecutar({ ...entrada, dispositivo: s.dispositivo, ip }));
  }

  @Post('con-contrasena')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    operationId: 'entrarConContrasena',
    summary: 'Entra al panel con correo (HU-02-02)',
  })
  @ApiOkResponse({ type: IngresoResponse })
  @ApiUnauthorizedResponse({ type: RespuestaErrorDto, description: 'No coinciden o bloqueada' })
  async conContrasena(
    @Body() s: IngresoConContrasenaRequest,
    @Ip() ip: string,
  ): Promise<IngresoResponse> {
    const entrada = { via: 'CONTRASENA' as const, identificador: s.correo, secreto: s.contrasena };
    return aRespuesta(await this.iniciar.ejecutar({ ...entrada, dispositivo: s.dispositivo, ip }));
  }

  @Post('pin-nuevo')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ operationId: 'crearPinNuevo', summary: 'Crea el PIN propio tras uno temporal' })
  @ApiOkResponse({ type: SesionResponse })
  @ApiUnauthorizedResponse({ type: RespuestaErrorDto, description: 'El paso se venció' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'PIN débil' })
  crearPin(@Body() solicitud: PinNuevoRequest): Promise<SesionResponse> {
    return this.definirPin.ejecutar(solicitud);
  }

  @Post('renovar')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ operationId: 'renovarSesion', summary: 'Cambia el token de renovación por otro' })
  @ApiOkResponse({ type: SesionResponse })
  @ApiUnauthorizedResponse({ type: RespuestaErrorDto, description: 'Sesión cerrada o vencida' })
  renovarSesion(@Body() solicitud: RenovarSesionRequest): Promise<SesionResponse> {
    return this.renovar.ejecutar(solicitud.tokenRenovacion);
  }

  @Post('salir')
  @RequiereSesion()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ operationId: 'salir', summary: 'Cierra la sesión en este dispositivo' })
  @ApiNoContentResponse()
  salir(@IdentidadActual() identidad: Identidad): Promise<void> {
    return this.cerrar.ejecutar(identidad);
  }
}
