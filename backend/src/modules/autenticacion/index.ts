// Interfaz pública del módulo: otros módulos solo importan desde aquí.
export { AutenticacionModule } from './autenticacion.module';
export { EmitirPinTemporal } from './application/use-cases/emitir-pin-temporal.use-case';
export type { MotivoPinTemporal } from './application/use-cases/emitir-pin-temporal.use-case';
export { Celular } from './domain/value-objects/celular.vo';
export { Correo } from './domain/value-objects/correo.vo';
export { EntrarConCuentaNueva } from './application/use-cases/entrar-con-cuenta-nueva.use-case';
export type { SesionOutput } from './application/dto/sesion.output';
export type { Dispositivo } from './application/puertos/sesiones.repository';
export { Pin } from './domain/value-objects/pin.vo';
export { DispositivoRequest } from './presentation/http/dispositivo.request';
export { SesionResponse } from './presentation/http/sesion.response';
