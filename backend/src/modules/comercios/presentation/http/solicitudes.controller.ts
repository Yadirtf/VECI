import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequierePlataforma } from '../../../../shared/presentation/http/decoradores/requiere-plataforma.decorator';
import { RequiereSesion } from '../../../../shared/presentation/http/decoradores/requiere-sesion.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { EstadoSolicitud } from '../../domain/entities/solicitud';
import { RevisarSolicitudes } from '../../application/use-cases/revisar-solicitudes.use-case';
import { SolicitarRegistroDeNegocio } from '../../application/use-cases/solicitar-registro.use-case';
import { ComercioRegistradoResponse } from './comercios.response';
import { RechazoSolicitudRequest, SolicitarRegistroRequest } from './solicitudes.request';
import { SolicitudResponse } from './solicitudes.response';

const ESTADOS: readonly EstadoSolicitud[] = ['PENDING', 'APPROVED', 'REJECTED'];

/**
 * Registrar un negocio es una solicitud que revisa Administración VECI: cualquier
 * persona con cuenta la pide, pero solo quien tiene platform.manage_tenants la decide.
 */
@ApiTags('Solicitudes de negocio')
@Controller()
export class SolicitudesController {
  constructor(
    private readonly solicitar: SolicitarRegistroDeNegocio,
    private readonly revisar: RevisarSolicitudes,
  ) {}

  @Post('solicitudes-de-negocio')
  @RequiereSesion()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ operationId: 'solicitarRegistroDeNegocio', summary: 'Pide registrar mi negocio' })
  @ApiNoContentResponse()
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya tiene una en revisión' })
  @ApiUnprocessableEntityResponse({
    type: RespuestaErrorDto,
    description: 'Datos inválidos o municipio sin cobertura',
  })
  radicar(
    @IdentidadActual() identidad: Identidad,
    @Body() s: SolicitarRegistroRequest,
  ): Promise<void> {
    return this.solicitar.ejecutar(identidad.usuarioId, s);
  }

  @Get('solicitudes-de-negocio')
  @RequiereSesion()
  @ApiOperation({ operationId: 'listarMisSolicitudesDeNegocio', summary: 'Mis solicitudes' })
  @ApiOkResponse({ type: SolicitudResponse, isArray: true })
  mias(@IdentidadActual() identidad: Identidad): Promise<SolicitudResponse[]> {
    return this.solicitar.mias(identidad.usuarioId);
  }

  @Get('plataforma/solicitudes-de-negocio')
  @RequierePlataforma('platform.manage_tenants')
  @ApiOperation({ operationId: 'listarSolicitudesDeNegocio', summary: 'Solicitudes por revisar' })
  @ApiQuery({ name: 'estado', required: false, enum: ESTADOS })
  @ApiOkResponse({ type: SolicitudResponse, isArray: true })
  listar(
    @IdentidadActual() identidad: Identidad,
    @Query('estado') estado?: string,
  ): Promise<SolicitudResponse[]> {
    const filtro = ESTADOS.find((e) => e === estado) ?? null;
    return this.revisar.listar(identidad.usuarioId, filtro);
  }

  @Post('plataforma/solicitudes-de-negocio/:solicitudId/aprobacion')
  @RequierePlataforma('platform.manage_tenants')
  @ApiOperation({
    operationId: 'aprobarSolicitudDeNegocio',
    summary: 'Aprueba: nace el negocio con quien lo pidió como propietaria',
  })
  @ApiCreatedResponse({ type: ComercioRegistradoResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya fue revisada' })
  aprobar(
    @IdentidadActual() identidad: Identidad,
    @Param('solicitudId', ParseUUIDPipe) solicitudId: string,
  ): Promise<ComercioRegistradoResponse> {
    return this.revisar.aprobar(identidad.usuarioId, solicitudId);
  }

  @Post('plataforma/solicitudes-de-negocio/:solicitudId/rechazo')
  @RequierePlataforma('platform.manage_tenants')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ operationId: 'rechazarSolicitudDeNegocio', summary: 'Rechaza y dice por qué' })
  @ApiNoContentResponse()
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya fue revisada' })
  rechazar(
    @IdentidadActual() identidad: Identidad,
    @Param('solicitudId', ParseUUIDPipe) solicitudId: string,
    @Body() s: RechazoSolicitudRequest,
  ): Promise<void> {
    return this.revisar.rechazar(identidad.usuarioId, solicitudId, s.motivo);
  }
}
