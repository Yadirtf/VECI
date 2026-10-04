import { Body, Controller, Get, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { CrearHorario } from '../../application/use-cases/crear-horario.use-case';
import { ListarHorarios } from '../../application/use-cases/listar-horarios.use-case';
import { CrearHorarioRequest } from './crear-horario.request';
import { HorarioResponse } from './horario.response';

@ApiTags('Horarios de servicio')
@RequiereComercio()
@Controller('horarios')
export class HorariosController {
  constructor(
    private readonly listarHorarios: ListarHorarios,
    private readonly crearHorario: CrearHorario,
  ) {}

  @Get()
  @RequierePermiso('tenancy.view_tenant')
  @ApiOperation({ operationId: 'listarHorarios', summary: 'Horarios vigentes del negocio' })
  @ApiOkResponse({ type: HorarioResponse, isArray: true })
  listar(): Promise<HorarioResponse[]> {
    return this.listarHorarios.ejecutar();
  }

  @Post()
  @RequierePermiso('tenancy.manage_schedules')
  @ApiOperation({ operationId: 'crearHorario', summary: 'Agrega un horario de servicio' })
  @ApiCreatedResponse({ type: HorarioResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Se cruza con otro horario' })
  @ApiNotFoundResponse({
    type: RespuestaErrorDto,
    description: 'El servicio o la sede no son del negocio',
  })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Horas o día inválidos' })
  crear(@Body() solicitud: CrearHorarioRequest): Promise<HorarioResponse> {
    return this.crearHorario.ejecutar(solicitud);
  }
}
