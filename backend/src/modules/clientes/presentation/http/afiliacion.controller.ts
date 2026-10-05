import { Body, Controller, HttpCode, HttpStatus, Inject, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
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
import { AfiliarPorQr } from '../../application/use-cases/afiliar-por-qr.use-case';
import { LeerQrDeCliente } from '../../application/use-cases/leer-qr.use-case';
import {
  RegistrarAsistido,
  RevisarDocumento,
} from '../../application/use-cases/registro-asistido.use-case';
import {
  AfiliacionResponse,
  LecturaQrResponse,
  RegistroAsistidoResponse,
  RevisionDocumentoResponse,
} from './clientes.response';
import { DocumentoRequest, RegistroAsistidoRequest, TokenQrRequest } from './registro.request';
import { aClienteResponse, verCompleto } from './vista-de-cliente';

/** La caja escanea, afilia y registra clientes (HU-04-03, HU-04-04). */
@ApiTags('Clientes')
@RequiereComercio()
@Controller('clientes')
export class AfiliacionController {
  constructor(
    private readonly leerQr: LeerQrDeCliente,
    private readonly afiliarPorQr: AfiliarPorQr,
    private readonly revisar: RevisarDocumento,
    private readonly registrarAsistido: RegistrarAsistido,
    @Inject(VERIFICADOR_MEMBRESIA) private readonly membresias: VerificadorMembresia,
  ) {}

  @Post('qr')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('customers.affiliate')
  @ApiOperation({ operationId: 'leerQrDeCliente', summary: 'Qué es el QR que escaneó la caja' })
  @ApiOkResponse({ type: LecturaQrResponse })
  async leer(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Body() s: TokenQrRequest,
  ): Promise<LecturaQrResponse> {
    const actor = { usuarioId: identidad.usuarioId, comercioId };
    const lectura = await this.leerQr.ejecutar(actor, s.token);
    if (lectura.resultado !== 'CLIENTE') return lectura;
    return {
      resultado: 'CLIENTE',
      cliente: aClienteResponse(lectura.cliente, await this.completo(actor)),
    };
  }

  @Post('afiliaciones')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('customers.affiliate')
  @ApiOperation({ operationId: 'afiliarPorQr', summary: 'Afilia con el QR personal (HU-04-03)' })
  @ApiOkResponse({ type: AfiliacionResponse })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'El QR no sirve' })
  async afiliar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Body() s: TokenQrRequest,
  ): Promise<AfiliacionResponse> {
    const actor = { usuarioId: identidad.usuarioId, comercioId };
    const { yaEstaba, cliente } = await this.afiliarPorQr.ejecutar(actor, s.token);
    return { yaEstaba, cliente: aClienteResponse(cliente, await this.completo(actor)) };
  }

  @Post('registro-asistido/revisar')
  @HttpCode(HttpStatus.OK)
  @RequierePermiso('customers.register')
  @ApiOperation({
    operationId: 'revisarDocumentoDeCliente',
    summary: '¿Ya está en VECI? Solo datos enmascarados (HU-04-04)',
  })
  @ApiOkResponse({ type: RevisionDocumentoResponse })
  revisarDocumento(@Body() s: DocumentoRequest): Promise<RevisionDocumentoResponse> {
    return this.revisar.ejecutar(s.tipoDocumento, s.numeroDocumento);
  }

  @Post('registro-asistido')
  @RequierePermiso('customers.register')
  @ApiOperation({
    operationId: 'registrarClienteAsistido',
    summary: 'Registra a quien no tiene la app (HU-04-04)',
  })
  @ApiCreatedResponse({ type: RegistroAsistidoResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Celular de otra cuenta' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Faltan datos' })
  async registrar(
    @IdentidadActual() identidad: Identidad,
    @ComercioActivo() comercioId: string,
    @Body() s: RegistroAsistidoRequest,
  ): Promise<RegistroAsistidoResponse> {
    const actor = { usuarioId: identidad.usuarioId, comercioId };
    const salida = await this.registrarAsistido.ejecutar(actor, {
      ...s,
      nombres: s.nombres ?? null,
      apellidos: s.apellidos ?? null,
      celular: s.celular ?? null,
      celularCompartido: s.celularCompartido ?? false,
    });
    return { ...salida, cliente: aClienteResponse(salida.cliente, await this.completo(actor)) };
  }

  private completo(actor: Actor): Promise<boolean> {
    return verCompleto(this.membresias, actor);
  }
}
