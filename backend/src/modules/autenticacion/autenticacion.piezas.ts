import { CifradorSecretos } from '../../shared/application/puertos/cifrador-secretos.port';
import { GeneradorSecretos } from '../../shared/application/puertos/generador-secretos.port';
import { Configuracion } from '../../shared/infrastructure/config/configuracion';
import { CredencialesRepository } from './application/puertos/credenciales.repository';
import { CuentasRepository } from './application/puertos/cuentas.repository';
import { SesionesRepository } from './application/puertos/sesiones.repository';

/** Piezas que casi todos los casos de uso del módulo necesitan, resueltas una vez. */
export interface Piezas {
  cuentas: CuentasRepository;
  credenciales: CredencialesRepository;
  sesiones: SesionesRepository;
  cifrador: CifradorSecretos;
  secretos: GeneradorSecretos;
  config: Configuracion;
}

export const PIEZAS = Symbol('PiezasAutenticacion');
