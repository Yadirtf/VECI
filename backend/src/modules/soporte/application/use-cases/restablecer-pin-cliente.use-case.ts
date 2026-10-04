import { Celular, EmitirPinTemporal } from '../../../autenticacion';
import { CuentaNoEncontrada, DocumentoNoCoincide } from '../../domain/errors/errores-soporte';
import { CuentasSoporteRepository } from '../puertos/cuentas-soporte.repository';

export interface RestablecerPinClienteInput {
  soporteUsuarioId: string;
  celular: string;
  tipoDocumento: string;
  numeroDocumento: string;
}

/**
 * Soporte VECI restablece el PIN de un cliente después de verificar su documento
 * (HU-02-05). La comparación la hace VECI: soporte nunca ve el documento completo.
 */
export class RestablecerPinCliente {
  constructor(
    private readonly cuentas: CuentasSoporteRepository,
    private readonly pinTemporal: EmitirPinTemporal,
  ) {}

  async ejecutar(
    entrada: RestablecerPinClienteInput,
  ): Promise<{ pinTemporal: string; nombre: string }> {
    const cuenta = await this.cuentas.buscarPorCelular(Celular.de(entrada.celular).valor);
    if (!cuenta) throw new CuentaNoEncontrada();
    const persona = await this.cuentas.buscarPorDocumento(
      entrada.tipoDocumento,
      entrada.numeroDocumento,
    );
    if (persona?.personaId !== cuenta.personaId) throw new DocumentoNoCoincide();
    const pinTemporal = await this.pinTemporal.ejecutar({
      usuarioId: cuenta.usuarioId,
      motivo: 'RESET_BY_SUPPORT',
      porUsuarioId: entrada.soporteUsuarioId,
      comercioId: null,
    });
    return { pinTemporal, nombre: persona.nombreEnmascarado };
  }
}
