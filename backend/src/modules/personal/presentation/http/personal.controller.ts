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
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
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
import { CambiarEstadoCajero } from '../../application/use-cases/cambiar-estado-cajero.use-case';
import { InvitarCajero } from '../../application/use-cases/invitar-cajero.use-case';
import { ListarPersonal } from '../../application/use-cases/listar-personal.use-case';
import { RestablecerPinCajero } from '../../application/use-cases/restablecer-pin-cajero.use-case';
import { CambiarEstadoCajeroRequest, InvitarCajeroRequest } from './personal.request';
import { InvitacionResponse, MiembroResponse, PinTemporalResponse } from './personal.response';

const UUID = new ParseUUIDPipe();

@ApiTags('Equipo del negocio')
@RequiereComercio()
@RequierePermiso('tenancy.manage_staff')
@Controller('equipo')
export class PersonalController {
  constructor(
    private readonly listarPersonal: ListarPersonal,
    private readonly invitarCajero: InvitarCajero,
    private readonly cambiarEstado: CambiarEstadoCajero,
    private readonly restablecerPin: RestablecerPinCajero,
  ) {}

  @Get()
  @ApiOperation({ operationId: 'listarEquipo', summary: 'Propietarios y cajeros del negocio' })
  @ApiOkResponse({ type: MiembroResponse, isArray: true })
  listar(): Promise<MiembroResponse[]> {
    return this.listarPersonal.ejecutar();
  }

  @Post('cajeros')
  @ApiOperation({
    operationId: 'invitarCajero',
    summary: 'Invita un cajero por su celular (HU-02-04)',
  })
  @ApiCreatedResponse({ type: InvitacionResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Sin cupo, ya está o otro celular' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Datos inválidos' })
  invitar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Body() s: InvitarCajeroRequest,
  ): Promise<InvitacionResponse> {
    const actor = { usuarioId: identidad.usuarioId, comercioId };
    return this.invitarCajero.ejecutar(actor, { ...s, apellidos: s.apellidos ?? null });
  }

  @Patch(':membresiaId/estado')
  @ApiOperation({ operationId: 'cambiarEstadoCajero', summary: 'Suspende, reactiva o retira' })
  @ApiOkResponse({ type: MiembroResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Cambio no permitido' })
  estado(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('membresiaId', UUID) membresiaId: string,
    @Body() s: CambiarEstadoCajeroRequest,
  ): Promise<MiembroResponse> {
    return this.cambiarEstado.ejecutar(
      { usuarioId: identidad.usuarioId, comercioId },
      membresiaId,
      s.accion,
    );
  }

  @Post(':membresiaId/restablecer-pin')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('tenancy.reset_staff_pin')
  @ApiOperation({
    operationId: 'restablecerPinCajero',
    summary: 'PIN temporal para un cajero (HU-02-05)',
  })
  @ApiOkResponse({ type: PinTemporalResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  restablecer(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('membresiaId', UUID) membresiaId: string,
  ): Promise<PinTemporalResponse> {
    return this.restablecerPin.ejecutar(
      { usuarioId: identidad.usuarioId, comercioId },
      membresiaId,
    );
  }
}
