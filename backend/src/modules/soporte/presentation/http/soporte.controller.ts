import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import {
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiProperty,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { IsString, Matches, MaxLength } from 'class-validator';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequierePlataforma } from '../../../../shared/presentation/http/decoradores/requiere-plataforma.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { RestablecerPinCliente } from '../../application/use-cases/restablecer-pin-cliente.use-case';

export class RestablecerPinClienteRequest {
  @ApiProperty({ example: '310 000 0103' })
  @IsString()
  @MaxLength(20)
  celular!: string;

  @ApiProperty({ example: 'CC' })
  @Matches(/^[A-Z][A-Z0-9_]*$/, { message: 'tipoDocumento debe ser un código como CC' })
  tipoDocumento!: string;

  @ApiProperty({ example: '1124500003', description: 'El que dice la persona por teléfono' })
  @Matches(/^[0-9A-Za-z]{4,20}$/, { message: 'Revisa el número de documento' })
  numeroDocumento!: string;
}

export class PinClienteResponse {
  @ApiProperty({ example: '730284', description: 'Se dicta una sola vez a la persona' })
  pinTemporal!: string;

  @ApiProperty({ example: 'Luz Marina C.', description: 'Nombre enmascarado para confirmar' })
  nombre!: string;
}

@ApiTags('Soporte VECI')
@Controller('soporte')
export class SoporteController {
  constructor(private readonly restablecer: RestablecerPinCliente) {}

  @Post('clientes/restablecer-pin')
  @HttpCode(HttpStatus.OK)
  @RequierePlataforma('platform.reset_customer_pin')
  @ApiOperation({
    operationId: 'restablecerPinCliente',
    summary: 'Restablece el PIN de un cliente tras verificar su documento (HU-02-05)',
  })
  @ApiOkResponse({ type: PinClienteResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto, description: 'Celular sin cuenta' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Documento distinto' })
  restablecerPin(
    @IdentidadActual() identidad: Identidad,
    @Body() s: RestablecerPinClienteRequest,
  ): Promise<PinClienteResponse> {
    return this.restablecer.ejecutar({ soporteUsuarioId: identidad.usuarioId, ...s });
  }
}
