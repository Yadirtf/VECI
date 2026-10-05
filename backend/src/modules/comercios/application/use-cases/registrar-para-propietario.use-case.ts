import { AlmacenContexto } from '../../../../shared/application/contexto/almacen-contexto.port';
import { InvitarCajero } from '../../../personal';
import { ComercioRegistradoOutput, RegistrarComercioInput } from '../dto/comercios.dto';
import { RegistrarComercio } from './registrar-comercio.use-case';

/** Quién será el propietario cuando VECI registra el negocio por él. */
export interface PropietarioInvitado {
  celular: string;
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  numeroDocumento: string;
}

export interface DependenciasRegistrarParaPropietario {
  registrar: RegistrarComercio;
  invitar: InvitarCajero;
  almacen: AlmacenContexto;
}

/**
 * Administración VECI registra el negocio de un dueño que aún no usa VECI (el
 * piloto empieza así). El dueño queda invitado como propietario con el mismo PIN
 * temporal que reciben los cajeros (ADR-0015): al entrar, crea el suyo.
 */
export class RegistrarComercioParaPropietario {
  constructor(private readonly d: DependenciasRegistrarParaPropietario) {}

  async ejecutar(
    adminId: string,
    entrada: RegistrarComercioInput,
    propietario: PropietarioInvitado,
  ): Promise<ComercioRegistradoOutput> {
    const registrado = await this.d.registrar.ejecutar(adminId, entrada, null);
    const actor = { usuarioId: adminId, comercioId: registrado.comercioId };
    this.d.almacen.fijarComercio(actor);
    const { pinTemporal } = await this.d.invitar.propietario(actor, propietario);
    return { ...registrado, pinTemporal };
  }
}
