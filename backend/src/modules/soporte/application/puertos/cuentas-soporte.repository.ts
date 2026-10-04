/** Cuenta encontrada por celular, con su persona para comparar el documento. */
export interface CuentaSoporte {
  usuarioId: string;
  personaId: string;
}

/** Persona con un documento, con el nombre enmascarado para confirmar por teléfono. */
export interface PersonaPorDocumento {
  personaId: string;
  nombreEnmascarado: string;
}

export interface CuentasSoporteRepository {
  buscarPorCelular(celular: string): Promise<CuentaSoporte | null>;
  buscarPorDocumento(tipo: string, numero: string): Promise<PersonaPorDocumento | null>;
}

export const CUENTAS_SOPORTE_REPOSITORY = Symbol('CuentasSoporteRepository');
