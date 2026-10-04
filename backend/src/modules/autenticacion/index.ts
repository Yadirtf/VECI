// Interfaz pública del módulo: otros módulos solo importan desde aquí.
export { AutenticacionModule } from './autenticacion.module';
export { EmitirPinTemporal } from './application/use-cases/emitir-pin-temporal.use-case';
export type { MotivoPinTemporal } from './application/use-cases/emitir-pin-temporal.use-case';
export { Celular } from './domain/value-objects/celular.vo';
