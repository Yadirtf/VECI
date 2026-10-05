import { FactoryProvider } from '@nestjs/common';
import { AUDITORIA, Auditoria } from '../../shared/application/puertos/auditoria.port';
import {
  CIFRADOR_SECRETOS,
  CifradorSecretos,
} from '../../shared/application/puertos/cifrador-secretos.port';
import { FIRMADOR_QR, FirmadorQr } from '../../shared/application/puertos/firmador-qr.port';
import { EmitirPinTemporal, EntrarConCuentaNueva } from '../autenticacion';
import { CLIENTES_REPOSITORY, ClientesRepository } from './application/puertos/clientes.repository';
import { MI_QR_REPOSITORY, MiQrRepository } from './application/puertos/mi-qr.repository';
import { POLITICA_REPOSITORY, PoliticaRepository } from './application/puertos/politica.repository';
import { REGISTRO_REPOSITORY, RegistroRepository } from './application/puertos/registro.repository';
import { LectorQr } from './application/servicios/lector-qr';
import { TokensQr } from './application/servicios/tokens-qr';
import { AfiliarPorQr } from './application/use-cases/afiliar-por-qr.use-case';
import {
  ConsultarClientes,
  DarPinDeBienvenida,
} from './application/use-cases/consultar-clientes.use-case';
import { ConsultarPolitica } from './application/use-cases/consultar-politica.use-case';
import { LeerQrDeCliente } from './application/use-cases/leer-qr.use-case';
import { MiQr } from './application/use-cases/mi-qr.use-case';
import { Registrarse } from './application/use-cases/registrarse.use-case';
import {
  RegistrarAsistido,
  RevisarDocumento,
} from './application/use-cases/registro-asistido.use-case';

/** Casos de uso del módulo, conectados con sus puertos (la aplicación no conoce NestJS). */
export const PROVEEDORES_CLIENTES: FactoryProvider[] = [
  {
    provide: TokensQr,
    useFactory: (firmador: FirmadorQr) => new TokensQr(firmador),
    inject: [FIRMADOR_QR],
  },
  {
    provide: LectorQr,
    useFactory: (clientes: ClientesRepository, tokens: TokensQr) => new LectorQr(clientes, tokens),
    inject: [CLIENTES_REPOSITORY, TokensQr],
  },
  {
    provide: ConsultarPolitica,
    useFactory: (politicas: PoliticaRepository) => new ConsultarPolitica(politicas),
    inject: [POLITICA_REPOSITORY],
  },
  {
    provide: Registrarse,
    useFactory: (
      registro: RegistroRepository,
      politicas: PoliticaRepository,
      cifrador: CifradorSecretos,
      entrar: EntrarConCuentaNueva,
    ) => new Registrarse({ registro, politicas, cifrador, entrar }),
    inject: [REGISTRO_REPOSITORY, POLITICA_REPOSITORY, CIFRADOR_SECRETOS, EntrarConCuentaNueva],
  },
  {
    provide: MiQr,
    useFactory: (repo: MiQrRepository, tokens: TokensQr, auditoria: Auditoria) =>
      new MiQr(repo, tokens, auditoria),
    inject: [MI_QR_REPOSITORY, TokensQr, AUDITORIA],
  },
  {
    provide: LeerQrDeCliente,
    useFactory: (lector: LectorQr, clientes: ClientesRepository) =>
      new LeerQrDeCliente(lector, clientes),
    inject: [LectorQr, CLIENTES_REPOSITORY],
  },
  {
    provide: AfiliarPorQr,
    useFactory: (
      clientes: ClientesRepository,
      lector: LectorQr,
      tokens: TokensQr,
      auditoria: Auditoria,
    ) => new AfiliarPorQr({ clientes, lector, tokens, auditoria }),
    inject: [CLIENTES_REPOSITORY, LectorQr, TokensQr, AUDITORIA],
  },
  {
    provide: RevisarDocumento,
    useFactory: (clientes: ClientesRepository) => new RevisarDocumento(clientes),
    inject: [CLIENTES_REPOSITORY],
  },
  {
    provide: RegistrarAsistido,
    useFactory: (
      ...[clientes, politicas, tokens, pinTemporal, auditoria]: [
        ClientesRepository,
        PoliticaRepository,
        TokensQr,
        EmitirPinTemporal,
        Auditoria,
      ]
    ) => new RegistrarAsistido({ clientes, politicas, tokens, pinTemporal, auditoria }),
    inject: [CLIENTES_REPOSITORY, POLITICA_REPOSITORY, TokensQr, EmitirPinTemporal, AUDITORIA],
  },
  {
    provide: ConsultarClientes,
    useFactory: (clientes: ClientesRepository) => new ConsultarClientes(clientes),
    inject: [CLIENTES_REPOSITORY],
  },
  {
    provide: DarPinDeBienvenida,
    useFactory: (clientes: ClientesRepository, pinTemporal: EmitirPinTemporal) =>
      new DarPinDeBienvenida(clientes, pinTemporal),
    inject: [CLIENTES_REPOSITORY, EmitirPinTemporal],
  },
];
