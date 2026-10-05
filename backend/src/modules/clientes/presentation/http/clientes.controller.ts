import {
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Inject,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  Res,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import {
  VERIFICADOR_MEMBRESIA,
  VerificadorMembresia,
} from '../../../../shared/application/contexto/verificador-membresia.port';
import { ComercioActivo } from '../../../../shared/presentation/http/decoradores/comercio-activo.decorator';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { Actor } from '../../application/dto/clientes.dto';
import {
  ConsultarClientes,
  DarPinDeBienvenida,
} from '../../application/use-cases/consultar-clientes.use-case';
import { ClienteResponse, CopiaLocalResponse, PinBienvenidaResponse } from './clientes.response';
import { aClienteEnCaja, aClienteResponse, verCompleto } from './vista-de-cliente';

const UUID = new ParseUUIDPipe();

/** Buscar y ver clientes del negocio, también sin internet (HU-04-05). */
@ApiTags('Clientes')
@RequiereComercio()
@Controller('clientes')
export class ClientesController {
  constructor(
    private readonly consultar: ConsultarClientes,
    private readonly pinDeBienvenida: DarPinDeBienvenida,
    @Inject(VERIFICADOR_MEMBRESIA) private readonly membresias: VerificadorMembresia,
  ) {}

  @Get()
  @RequierePermiso('customers.search')
  @ApiOperation({
    operationId: 'buscarClientes',
    summary: 'Por nombre, celular o documento (HU-04-05)',
  })
  @ApiQuery({ name: 'q', description: 'Desde 3 letras o números', example: 'luz' })
  @ApiOkResponse({ type: ClienteResponse, isArray: true })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Muy corta' })
  async buscar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Query('q') q = '',
  ): Promise<ClienteResponse[]> {
    const completo = await this.completo({ usuarioId: identidad.usuarioId, comercioId });
    return (await this.consultar.buscar(q)).map((c) => aClienteResponse(c, completo));
  }

  @Get('copia-local')
  @RequierePermiso('customers.search')
  @ApiOperation({
    operationId: 'bajarCopiaLocalDeClientes',
    summary: 'Copia para buscar sin internet; 304 si no cambió (HU-04-05)',
  })
  @ApiOkResponse({ type: CopiaLocalResponse })
  @ApiResponse({ status: HttpStatus.NOT_MODIFIED, description: 'La copia del celular está al día' })
  async copiaLocal(
    @Headers('if-none-match') etag: string | undefined,
    @Res({ passthrough: true }) respuesta: Response,
  ): Promise<CopiaLocalResponse | undefined> {
    const actual = `"${await this.consultar.versionDeCopia()}"`;
    respuesta.setHeader('ETag', actual);
    if (etag === actual) {
      respuesta.status(HttpStatus.NOT_MODIFIED);
      return undefined;
    }
    const copia = await this.consultar.copiaLocal();
    respuesta.setHeader('ETag', `"${copia.version}"`);
    return {
      version: copia.version,
      clientes: copia.clientes.map(aClienteEnCaja),
      claves: copia.claves.map((c) => ({
        keyId: c.keyId,
        clavePublica: Buffer.from(c.publica).toString('base64url'),
      })),
    };
  }

  @Get(':clienteId')
  @RequierePermiso('customers.search')
  @ApiOperation({ operationId: 'consultarCliente', summary: 'Ficha del cliente' })
  @ApiOkResponse({ type: ClienteResponse })
  @ApiNotFoundResponse({ type: RespuestaErrorDto })
  async ficha(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('clienteId', UUID) clienteId: string,
  ): Promise<ClienteResponse> {
    const completo = await this.completo({ usuarioId: identidad.usuarioId, comercioId });
    return aClienteResponse(await this.consultar.ficha(clienteId), completo);
  }

  @Post(':clienteId/pin-bienvenida')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('customers.register')
  @ApiOperation({
    operationId: 'darPinDeBienvenida',
    summary: 'PIN nuevo para activar la app (HU-04-04)',
  })
  @ApiOkResponse({ type: PinBienvenidaResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya activó su app' })
  pin(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Param('clienteId', UUID) clienteId: string,
  ): Promise<PinBienvenidaResponse> {
    return this.pinDeBienvenida.ejecutar({ usuarioId: identidad.usuarioId, comercioId }, clienteId);
  }

  private completo(actor: Actor): Promise<boolean> {
    return verCompleto(this.membresias, actor);
  }
}
