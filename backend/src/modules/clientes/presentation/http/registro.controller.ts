import { Body, Controller, Get, HttpCode, HttpStatus, Ip, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereSesion } from '../../../../shared/presentation/http/decoradores/requiere-sesion.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { SesionResponse } from '../../../autenticacion';
import { ConsultarPolitica } from '../../application/use-cases/consultar-politica.use-case';
import { MiQr } from '../../application/use-cases/mi-qr.use-case';
import { Registrarse } from '../../application/use-cases/registrarse.use-case';
import { RegistroRequest } from './registro.request';
import {
  MiComercioResponse,
  MiQrResponse,
  PoliticaResponse,
  TipoDocumentoResponse,
} from './registro.response';

/** Lo público del registro del cliente (HU-04-01, HU-12-01). */
@ApiTags('Registro del cliente')
@Controller()
export class RegistroController {
  constructor(
    private readonly politica: ConsultarPolitica,
    private readonly registrarse: Registrarse,
  ) {}

  @Get('politica-de-datos')
  @ApiOperation({ operationId: 'consultarPoliticaDeDatos', summary: 'Política de datos vigente' })
  @ApiOkResponse({ type: PoliticaResponse })
  consultarPolitica(): Promise<PoliticaResponse> {
    return this.politica.ejecutar();
  }

  @Get('registro/tipos-documento')
  @ApiOperation({ operationId: 'listarTiposDeDocumento', summary: 'Documentos de personas' })
  @ApiOkResponse({ type: TipoDocumentoResponse, isArray: true })
  tiposDeDocumento(): Promise<TipoDocumentoResponse[]> {
    return this.registrarse.tiposDeDocumento();
  }

  @Post('registro')
  @ApiOperation({
    operationId: 'registrarme',
    summary: 'El cliente crea su cuenta y entra (HU-04-01)',
  })
  @ApiCreatedResponse({ type: SesionResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya tiene cuenta o la anotaron' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Datos inválidos' })
  registrar(@Body() s: RegistroRequest, @Ip() ip: string): Promise<SesionResponse> {
    return this.registrarse.ejecutar({ ...s, apellidos: s.apellidos ?? null, ip: ip || null });
  }
}

/** El QR personal y los negocios del cliente en su app (HU-04-02, HU-04-03). */
@ApiTags('Registro del cliente')
@RequiereSesion()
@Controller()
export class MiQrController {
  constructor(private readonly miQr: MiQr) {}

  @Get('mi-qr')
  @ApiOperation({ operationId: 'consultarMiQr', summary: 'Mi QR personal para afiliarme' })
  @ApiOkResponse({ type: MiQrResponse })
  consultar(@IdentidadActual() identidad: Identidad): Promise<MiQrResponse> {
    return this.miQr.consultar(identidad.usuarioId);
  }

  @Post('mi-qr/regenerar')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    operationId: 'regenerarMiQr',
    summary: 'QR nuevo; el anterior deja de servir (HU-04-02)',
  })
  @ApiOkResponse({ type: MiQrResponse })
  regenerar(@IdentidadActual() identidad: Identidad): Promise<MiQrResponse> {
    return this.miQr.regenerar(identidad.usuarioId);
  }

  @Get('mis-comercios')
  @ApiOperation({
    operationId: 'listarMisComercios',
    summary: 'Negocios donde soy cliente, con mi QR en cada uno',
  })
  @ApiOkResponse({ type: MiComercioResponse, isArray: true })
  comercios(@IdentidadActual() identidad: Identidad): Promise<MiComercioResponse[]> {
    return this.miQr.comercios(identidad.usuarioId);
  }
}
