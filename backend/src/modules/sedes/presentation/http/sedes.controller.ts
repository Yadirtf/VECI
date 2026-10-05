import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { GestionarSedes } from '../../application/use-cases/sedes.use-case';
import {
  AsignarSedesRequest,
  CrearSedeRequest,
  EditarSedeRequest,
  MapaDeSedesResponse,
  SedeResponse,
} from './sedes.dto';

const UUID = new ParseUUIDPipe();

@ApiTags('Sedes')
@RequiereComercio()
@Controller('sedes')
export class SedesController {
  constructor(private readonly sedes: GestionarSedes) {}

  @Get()
  @RequierePermiso('tenancy.view_tenant')
  @ApiOperation({ operationId: 'listarSedes', summary: 'Sedes, cajeros por sede y cupo del plan' })
  @ApiOkResponse({ type: MapaDeSedesResponse })
  listar(): Promise<MapaDeSedesResponse> {
    return this.sedes.mapa();
  }

  @Post()
  @RequierePermiso('tenancy.manage_branches')
  @ApiOperation({ operationId: 'crearSede', summary: 'Abre otra sede (plan Pro, HU-03-03)' })
  @ApiCreatedResponse({ type: SedeResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'El plan no lo permite' })
  crear(@Body() s: CrearSedeRequest): Promise<SedeResponse> {
    return this.sedes.crear({
      nombre: s.nombre,
      municipioId: s.municipioId ?? null,
      direccion: s.direccion?.trim() || null,
    });
  }

  @Patch(':sedeId')
  @RequierePermiso('tenancy.manage_branches')
  @ApiOperation({ operationId: 'editarSede', summary: 'Cambia, desactiva o reabre una sede' })
  @ApiOkResponse({ type: SedeResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiUnprocessableEntityResponse({
    type: RespuestaErrorDto,
    description: 'La principal no se cierra',
  })
  editar(
    @Param('sedeId', UUID) sedeId: string,
    @Body() s: EditarSedeRequest,
  ): Promise<SedeResponse> {
    return this.sedes.editar(sedeId, s);
  }

  @Put('cajeros/:membresiaId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @RequierePermiso('tenancy.manage_branches', 'tenancy.manage_staff')
  @ApiOperation({ operationId: 'asignarSedesACajero', summary: 'Sedes donde trabaja un cajero' })
  @ApiNoContentResponse()
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  async asignar(
    @IdentidadActual() identidad: Identidad,
    @Param('membresiaId', UUID) membresiaId: string,
    @Body() s: AsignarSedesRequest,
  ): Promise<void> {
    await this.sedes.asignar(membresiaId, s.sedeIds, identidad.usuarioId);
  }
}
