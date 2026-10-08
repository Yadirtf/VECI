import {
  Body,
  Controller,
  Get,
  Headers,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
  Res,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiHeader,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { CambiarHorario } from '../../application/use-cases/cambiar-horario.use-case';
import { CrearHorario } from '../../application/use-cases/crear-horario.use-case';
import { ProgramarServicio } from '../../application/use-cases/programar-servicio.use-case';
import { ListarHorarios } from '../../application/use-cases/listar-horarios.use-case';
import {
  CrearHorarioRequest,
  EditarHorarioRequest,
  EstadoHorarioRequest,
} from './crear-horario.request';
import { HorarioResponse } from './horario.response';

const UUID = new ParseUUIDPipe();

@ApiTags('Horarios de servicio')
@RequiereComercio()
@Controller('horarios')
export class HorariosController {
  constructor(
    private readonly listarHorarios: ListarHorarios,
    private readonly crearHorario: CrearHorario,
    private readonly cambiarHorario: CambiarHorario,
    private readonly programarServicio: ProgramarServicio,
  ) {}

  /**
   * La caja guarda la ETag y la manda en If-None-Match: si nada cambió, recibe un
   * 304 sin cuerpo y sigue con su copia (HU-03-02, "en la siguiente sincronización").
   */
  @Get()
  @RequierePermiso('tenancy.view_tenant')
  @ApiOperation({ operationId: 'listarHorarios', summary: 'Horarios vigentes del negocio' })
  @ApiHeader({ name: 'If-None-Match', required: false, description: 'ETag de la copia local' })
  @ApiOkResponse({ type: HorarioResponse, isArray: true })
  @ApiResponse({ status: 304, description: 'La copia local está al día' })
  async listar(
    @Headers('if-none-match') copiaLocal: string | undefined,
    @Res({ passthrough: true }) respuesta: Response,
  ): Promise<HorarioResponse[] | undefined> {
    const etag = `"h${await this.listarHorarios.version()}"`;
    respuesta.setHeader('ETag', etag);
    respuesta.setHeader('Cache-Control', 'no-cache');
    if (copiaLocal === etag) {
      respuesta.status(304);
      return undefined;
    }
    return this.listarHorarios.ejecutar();
  }

  @Post()
  @RequierePermiso('tenancy.manage_schedules')
  @ApiOperation({ operationId: 'crearHorario', summary: 'Agrega un horario en uno o varios días' })
  @ApiCreatedResponse({ type: HorarioResponse, isArray: true })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Se cruza con otro horario' })
  @ApiNotFoundResponse({
    type: RespuestaErrorDto,
    description: 'El servicio o la sede no son del negocio',
  })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Horas o día inválidos' })
  crear(@Body() solicitud: CrearHorarioRequest): Promise<HorarioResponse[]> {
    return this.crearHorario.ejecutar(solicitud);
  }

  /**
   * "Almuerzo de 11:30 a 15:00 de lunes a viernes": deja ese servicio con esas horas
   * en cada día elegido. Reemplaza el que ya tenía y crea el que faltaba.
   */
  @Put('programacion')
  @RequierePermiso('tenancy.manage_schedules')
  @ApiOperation({
    operationId: 'programarServicio',
    summary: 'Deja un servicio con las mismas horas en uno o varios días',
  })
  @ApiOkResponse({ type: HorarioResponse, isArray: true })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Algún día se cruza con otro' })
  @ApiNotFoundResponse({
    type: RespuestaErrorDto,
    description: 'El servicio o la sede no son del negocio',
  })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Horas o día inválidos' })
  programar(@Body() solicitud: CrearHorarioRequest): Promise<HorarioResponse[]> {
    return this.programarServicio.ejecutar(solicitud);
  }

  @Patch(':id')
  @RequierePermiso('tenancy.manage_schedules')
  @ApiOperation({
    operationId: 'editarHorario',
    summary: 'Cambia las horas desde hoy (devuelve el horario con su id nuevo)',
  })
  @ApiOkResponse({ type: HorarioResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Se cruza con otro horario' })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  editar(
    @Param('id', UUID) id: string,
    @Body() solicitud: EditarHorarioRequest,
  ): Promise<HorarioResponse> {
    return this.cambiarHorario.editar(id, solicitud);
  }

  @Patch(':id/estado')
  @RequierePermiso('tenancy.manage_schedules')
  @ApiOperation({ operationId: 'cambiarEstadoHorario', summary: 'Pone en pausa o reanuda' })
  @ApiOkResponse({ type: HorarioResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Al reanudar se cruza con otro' })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  estado(
    @Param('id', UUID) id: string,
    @Body() solicitud: EstadoHorarioRequest,
  ): Promise<HorarioResponse> {
    return this.cambiarHorario.cambiarEstado(id, solicitud.activo);
  }
}
