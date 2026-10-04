import { Controller, Get, HttpStatus, Res } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiServiceUnavailableResponse,
  ApiTags,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { ConsultarSalud } from '../../application/use-cases/consultar-salud.use-case';
import { SaludResponse } from './salud.response';

@ApiTags('Salud')
@Controller('salud')
export class SaludController {
  constructor(private readonly consultarSalud: ConsultarSalud) {}

  @Get()
  @ApiOperation({ operationId: 'consultarSalud', summary: 'Estado de la API y la base' })
  @ApiOkResponse({ type: SaludResponse })
  @ApiServiceUnavailableResponse({ type: SaludResponse })
  async consultar(@Res({ passthrough: true }) respuesta: Response): Promise<SaludResponse> {
    const salud = await this.consultarSalud.ejecutar();
    if (salud.estado !== 'ok') respuesta.status(HttpStatus.SERVICE_UNAVAILABLE);
    return salud;
  }
}
