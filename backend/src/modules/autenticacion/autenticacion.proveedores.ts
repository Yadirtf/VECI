import { FactoryProvider, InjectionToken } from '@nestjs/common';
import {
  VERIFICADOR_MEMBRESIA,
  VerificadorMembresia,
} from '../../shared/application/contexto/verificador-membresia.port';
import { AUDITORIA, Auditoria } from '../../shared/application/puertos/auditoria.port';
import { CIFRADOR_SECRETOS } from '../../shared/application/puertos/cifrador-secretos.port';
import {
  FIRMADOR_TOKENS,
  FirmadorTokens,
} from '../../shared/application/puertos/firmador-tokens.port';
import { GENERADOR_IDS, GeneradorIds } from '../../shared/application/puertos/generador-ids.port';
import { GENERADOR_SECRETOS } from '../../shared/application/puertos/generador-secretos.port';
import { Reloj, RELOJ } from '../../shared/application/puertos/reloj.port';
import { CONFIGURACION, Configuracion } from '../../shared/infrastructure/config/configuracion';
import {
  ALCANCE_DE_CUENTAS,
  AlcanceDeCuentas,
} from './application/puertos/alcance-de-cuentas.port';
import { CREDENCIALES_REPOSITORY } from './application/puertos/credenciales.repository';
import { CUENTAS_REPOSITORY } from './application/puertos/cuentas.repository';
import { ESPACIOS_REPOSITORY, EspaciosRepository } from './application/puertos/espacios.repository';
import { INTENTOS_INGRESO, IntentosIngreso } from './application/puertos/intentos-ingreso.port';
import { SESIONES_REPOSITORY } from './application/puertos/sesiones.repository';
import { ComprobadorCredencial } from './application/servicios/comprobador-credencial';
import { EmisorSesion } from './application/servicios/emisor-sesion';
import { ActivarComercio } from './application/use-cases/activar-comercio.use-case';
import { CambiarPin } from './application/use-cases/cambiar-pin.use-case';
import { CerrarSesion } from './application/use-cases/cerrar-sesion.use-case';
import { ConsultarEspacios } from './application/use-cases/consultar-espacios.use-case';
import { DefinirCorreoYContrasena } from './application/use-cases/definir-correo-y-contrasena.use-case';
import { DefinirPinNuevo } from './application/use-cases/definir-pin-nuevo.use-case';
import { EmitirPinTemporal } from './application/use-cases/emitir-pin-temporal.use-case';
import { EntrarConCuentaNueva } from './application/use-cases/entrar-con-cuenta-nueva.use-case';
import { IniciarSesion } from './application/use-cases/iniciar-sesion.use-case';
import { RenovarSesion } from './application/use-cases/renovar-sesion.use-case';
import { PIEZAS, Piezas } from './autenticacion.piezas';

/** Proveedor de fábrica que recibe primero las piezas comunes del módulo. */
function fabrica<T>(
  provide: InjectionToken,
  crear: (piezas: Piezas, ...otros: never[]) => T,
  inject: InjectionToken[] = [],
): FactoryProvider<T> {
  const useFactory = crear as unknown as (...args: unknown[]) => T;
  return { provide, useFactory, inject: [PIEZAS, ...inject] };
}

const reglas = (config: Configuracion) => ({
  segundosAcceso: config.segundosAcceso,
  diasSesion: config.diasSesion,
});

/** Casos de uso y servicios de la autenticación, conectados con sus puertos. */
export const PROVEEDORES_AUTENTICACION: FactoryProvider[] = [
  {
    provide: PIEZAS,
    useFactory: (
      ...[cuentas, credenciales, sesiones, cifrador, secretos, config]: never[]
    ): Piezas => ({
      cuentas,
      credenciales,
      sesiones,
      cifrador,
      secretos,
      config,
    }),
    inject: [
      CUENTAS_REPOSITORY,
      CREDENCIALES_REPOSITORY,
      SESIONES_REPOSITORY,
      CIFRADOR_SECRETOS,
      GENERADOR_SECRETOS,
      CONFIGURACION,
    ],
  },
  fabrica(
    ConsultarEspacios,
    (p, espacios: EspaciosRepository) => new ConsultarEspacios(espacios, p.cuentas),
    [ESPACIOS_REPOSITORY],
  ),
  fabrica(
    ComprobadorCredencial,
    (p, intentos: IntentosIngreso, auditoria: Auditoria, reloj: Reloj) =>
      new ComprobadorCredencial({ ...p, intentos, auditoria, reloj }),
    [INTENTOS_INGRESO, AUDITORIA, RELOJ],
  ),
  fabrica(
    EmisorSesion,
    (p, espacios: ConsultarEspacios, firmador: FirmadorTokens, ids: GeneradorIds, reloj: Reloj) =>
      new EmisorSesion({ ...p, espacios, firmador, ids, reloj, reglas: reglas(p.config) }),
    [ConsultarEspacios, FIRMADOR_TOKENS, GENERADOR_IDS, RELOJ],
  ),
  fabrica(
    IniciarSesion,
    (
      p,
      intentos: IntentosIngreso,
      comprobador: ComprobadorCredencial,
      firmador: FirmadorTokens,
      emisor: EmisorSesion,
    ) => new IniciarSesion({ ...p, intentos, comprobador, firmador, emisor }),
    [INTENTOS_INGRESO, ComprobadorCredencial, FIRMADOR_TOKENS, EmisorSesion],
  ),
  fabrica(
    DefinirPinNuevo,
    (p, firmador: FirmadorTokens, emisor: EmisorSesion) =>
      new DefinirPinNuevo({ ...p, firmador, emisor }),
    [FIRMADOR_TOKENS, EmisorSesion],
  ),
  fabrica(
    RenovarSesion,
    (p, emisor: EmisorSesion, reloj: Reloj) => new RenovarSesion({ ...p, emisor, reloj }),
    [EmisorSesion, RELOJ],
  ),
  fabrica(CerrarSesion, (p) => new CerrarSesion(p.sesiones)),
  fabrica(
    EntrarConCuentaNueva,
    (p, emisor: EmisorSesion) => new EntrarConCuentaNueva(p.cuentas, emisor),
    [EmisorSesion],
  ),
  fabrica(
    CambiarPin,
    (p, comprobador: ComprobadorCredencial) => new CambiarPin({ ...p, comprobador }),
    [ComprobadorCredencial],
  ),
  fabrica(
    DefinirCorreoYContrasena,
    (p, comprobador: ComprobadorCredencial) => new DefinirCorreoYContrasena({ ...p, comprobador }),
    [ComprobadorCredencial],
  ),
  fabrica(
    ActivarComercio,
    (
      _p,
      espacios: EspaciosRepository,
      consultar: ConsultarEspacios,
      membresias: VerificadorMembresia,
      auditoria: Auditoria,
    ) => new ActivarComercio({ espacios, consultar, membresias, auditoria }),
    [ESPACIOS_REPOSITORY, ConsultarEspacios, VERIFICADOR_MEMBRESIA, AUDITORIA],
  ),
  fabrica(
    EmitirPinTemporal,
    (p, auditoria: Auditoria, alcance: AlcanceDeCuentas) =>
      new EmitirPinTemporal({ ...p, auditoria, alcance }),
    [AUDITORIA, ALCANCE_DE_CUENTAS],
  ),
];
