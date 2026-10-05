import { Body, Controller, Get, HttpCode, HttpStatus, Patch, Post } from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnprocessableEntityResponse,
} from '@nestjs/swagger';
import { Identidad } from '../../../../shared/application/contexto/identidad';
import { IdentidadActual } from '../../../../shared/presentation/http/decoradores/identidad-actual.decorator';
import { RequiereComercio } from '../../../../shared/presentation/http/decoradores/requiere-comercio.decorator';
import { RequierePermiso } from '../../../../shared/presentation/http/decoradores/requiere-permiso.decorator';
import { RequierePlataforma } from '../../../../shared/presentation/http/decoradores/requiere-plataforma.decorator';
import { RequiereSesion } from '../../../../shared/presentation/http/decoradores/requiere-sesion.decorator';
import { RespuestaErrorDto } from '../../../../shared/presentation/http/respuesta-error.dto';
import { CatalogosDeComercio } from '../../application/use-cases/catalogos.use-case';
import { PerfilDelComercio } from '../../application/use-cases/perfil-comercio.use-case';
import { RegistrarComercio } from '../../application/use-cases/registrar-comercio.use-case';
import { RegistrarComercioParaPropietario } from '../../application/use-cases/registrar-para-propietario.use-case';
import {
  EditarComercioRequest,
  RegistrarComercioRequest,
  RegistrarParaPropietarioRequest,
} from './comercios.request';
import {
  ComercioRegistradoResponse,
  MunicipioResponse,
  PerfilComercioResponse,
  TipoDeNegocioResponse,
} from './comercios.response';

@ApiTags('Comercios')
@Controller()
export class ComerciosController {
  constructor(
    private readonly catalogos: CatalogosDeComercio,
    private readonly registrar: RegistrarComercio,
    private readonly registrarParaPropietario: RegistrarComercioParaPropietario,
    private readonly perfil: PerfilDelComercio,
  ) {}

  @Get('comercios/tipos')
  @RequiereSesion()
  @ApiOperation({ operationId: 'listarTiposDeNegocio', summary: 'Tipos de negocio y servicios' })
  @ApiOkResponse({ type: TipoDeNegocioResponse, isArray: true })
  tipos(): Promise<TipoDeNegocioResponse[]> {
    return this.catalogos.tiposDeNegocio();
  }

  @Get('comercios/municipios')
  @RequiereSesion()
  @ApiOperation({ operationId: 'listarMunicipios', summary: 'Municipios donde opera VECI' })
  @ApiOkResponse({ type: MunicipioResponse, isArray: true })
  municipios(): Promise<MunicipioResponse[]> {
    return this.catalogos.municipios();
  }

  @Post('comercios')
  @RequiereSesion()
  @ApiOperation({
    operationId: 'registrarComercio',
    summary: 'Registra un negocio propio (HU-03-01)',
  })
  @ApiCreatedResponse({ type: ComercioRegistradoResponse })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Datos inválidos' })
  registrarPropio(
    @IdentidadActual() identidad: Identidad,
    @Body() s: RegistrarComercioRequest,
  ): Promise<ComercioRegistradoResponse> {
    return this.registrar.ejecutar(identidad.usuarioId, s);
  }

  @Post('plataforma/comercios')
  @RequierePlataforma('platform.manage_tenants')
  @ApiOperation({
    operationId: 'registrarComercioParaPropietario',
    summary: 'Administración VECI registra un negocio e invita a su dueño (HU-03-01)',
  })
  @ApiCreatedResponse({ type: ComercioRegistradoResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'El celular es de otra persona' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Datos inválidos' })
  registrarAjeno(
    @IdentidadActual() identidad: Identidad,
    @Body() s: RegistrarParaPropietarioRequest,
  ): Promise<ComercioRegistradoResponse> {
    const { propietario, ...negocio } = s;
    return this.registrarParaPropietario.ejecutar(identidad.usuarioId, negocio, {
      ...propietario,
      apellidos: propietario.apellidos ?? null,
    });
  }

  @Get('comercio')
  @RequiereComercio()
  @RequierePermiso('tenancy.view_tenant')
  @ApiOperation({ operationId: 'consultarComercio', summary: 'Datos, plan y camino para abrir' })
  @ApiOkResponse({ type: PerfilComercioResponse })
  consultar(): Promise<PerfilComercioResponse> {
    return this.perfil.consultar();
  }

  @Patch('comercio')
  @RequiereComercio()
  @RequierePermiso('tenancy.manage_tenant')
  @ApiOperation({ operationId: 'editarComercio', summary: 'Cambia los datos del negocio' })
  @ApiOkResponse({ type: PerfilComercioResponse })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Datos inválidos' })
  editar(@Body() s: EditarComercioRequest): Promise<PerfilComercioResponse> {
    return this.perfil.editar(s);
  }

  @Post('comercio/abrir')
  @HttpCode(HttpStatus.OK)
  @RequiereComercio()
  @RequierePermiso('tenancy.manage_tenant')
  @ApiOperation({ operationId: 'abrirComercio', summary: 'Abre el negocio para vender' })
  @ApiOkResponse({ type: PerfilComercioResponse })
  @ApiConflictResponse({ type: RespuestaErrorDto, description: 'Ya estaba abierto' })
  @ApiUnprocessableEntityResponse({ type: RespuestaErrorDto, description: 'Falta un horario' })
  abrir(): Promise<PerfilComercioResponse> {
    return this.perfil.abrir();
  }
}
