import { Body, Controller, Get, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { GestionarServicios } from '../../application/use-cases/servicios.use-case';
import { CrearServicioRequest } from './crear-horario.request';
import { ServicioResponse } from './horario.response';

@ApiTags('Horarios de servicio')
@RequiereComercio()
@Controller('servicios')
export class ServiciosController {
  constructor(private readonly servicios: GestionarServicios) {}

  @Get()
  @RequierePermiso('tenancy.view_tenant')
  @ApiOperation({ operationId: 'listarServicios', summary: 'Servicios del negocio' })
  @ApiOkResponse({ type: ServicioResponse, isArray: true })
  listar(): Promise<ServicioResponse[]> {
    return this.servicios.listar();
  }

  @Post()
  @RequierePermiso('tenancy.manage_schedules')
  @ApiOperation({ operationId: 'crearServicio', summary: 'Agrega un servicio (cena, onces...)' })
  @ApiCreatedResponse({ type: ServicioResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya existe con ese nombre' })
  crear(@Body() solicitud: CrearServicioRequest): Promise<ServicioResponse> {
    return this.servicios.crear(solicitud.nombre);
  }
}
