import { Auditoria } from '../../../../shared/application/puertos/auditoria.port';
import { GeneradorIds } from '../../../../shared/application/puertos/generador-ids.port';
import { Celular, Correo } from '../../../autenticacion';
import { TipoDeNegocioDesconocido } from '../../domain/errors/errores-comercios';
import { MunicipioFueraDeCobertura } from '../../domain/errors/errores-solicitudes';
import { DocumentoNegocio } from '../../domain/value-objects/documento-negocio.vo';
import { Logo } from '../../domain/value-objects/logo.vo';
import { NombreNegocio } from '../../domain/value-objects/nombre-negocio.vo';
import { ComercioRegistradoOutput, RegistrarComercioInput } from '../dto/comercios.dto';
import { AltaDeComercio, ComerciosRepository } from '../puertos/comercios.repository';

export interface DependenciasRegistrar {
  comercios: ComerciosRepository;
  ids: GeneradorIds;
  auditoria: Auditoria;
}

/**
 * Registra un negocio (HU-03-01). Nace en configuración con su sede principal, los
 * servicios de su tipo, el plan de Prueba y, si ya se sabe quién es, la membresía de
 * su propietario. Todo en una transacción: o queda completo o no queda. Solo lo usa
 * Administración VECI: la persona dueña pide el registro con una solicitud.
 */
export class RegistrarComercio {
  constructor(private readonly d: DependenciasRegistrar) {}

  async ejecutar(
    actorId: string,
    entrada: RegistrarComercioInput,
    propietarioId: string | null = actorId,
  ): Promise<ComercioRegistradoOutput> {
    const alta = await this.preparar(actorId, entrada, propietarioId);
    const slug = await this.d.comercios.registrar(alta);
    await this.d.auditoria.registrar({
      accion: 'TENANT_CREATED',
      tabla: 'tenancy.tenants',
      entidadId: alta.comercioId,
      actorUsuarioId: actorId,
      comercioId: alta.comercioId,
      despues: { nombre: alta.nombre.valor, tipo: alta.tipoNegocio, slug },
    });
    return { comercioId: alta.comercioId, slug };
  }

  /** Valida los datos contra los catálogos y arma el alta, sin guardar nada. */
  async preparar(
    actorId: string,
    e: RegistrarComercioInput,
    propietarioId: string | null,
  ): Promise<AltaDeComercio> {
    const tipos = await this.d.comercios.tiposDeNegocio();
    if (!tipos.some((tipo) => tipo.codigo === e.tipoNegocio)) throw new TipoDeNegocioDesconocido();
    if (e.municipioId != null) {
      const atendidos = await this.d.comercios.municipios();
      if (!atendidos.some((m) => m.id === e.municipioId)) throw new MunicipioFueraDeCobertura();
    }
    return {
      comercioId: this.d.ids.siguiente(),
      nombre: NombreNegocio.de(e.nombre),
      documento: DocumentoNegocio.de(e.tipoDocumento, e.numeroDocumento),
      tipoNegocio: e.tipoNegocio,
      celular: Celular.de(e.celular).valor,
      correo: e.correo ? Correo.de(e.correo).valor : null,
      logoUrl: e.logoUrl ? Logo.de(e.logoUrl).url : null,
      municipioId: e.municipioId ?? null,
      direccion: e.direccion?.trim() || null,
      propietarioId,
      creadoPor: actorId,
    };
  }
}
