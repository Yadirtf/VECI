import { FactoryProvider } from '@nestjs/common';
import { GENERADOR_IDS, GeneradorIds } from '../../shared/application/puertos/generador-ids.port';
import {
  OBSERVABILIDAD,
  Observabilidad,
} from '../../shared/application/puertos/observabilidad.port';
import { RELOJ, Reloj } from '../../shared/application/puertos/reloj.port';
import { SALDOS_REPOSITORY, SaldosRepository } from './application/puertos/saldos.repository';
import { TIPOS_REPOSITORY, TiposRepository } from './application/puertos/tipos.repository';
import {
  VENCIMIENTO_REPOSITORY,
  VencimientoRepository,
} from './application/puertos/vencimiento.repository';
import { VENTAS_REPOSITORY, VentasRepository } from './application/puertos/ventas.repository';
import {
  ConsultarMisTiqueteras,
  ConsultarSaldoDelCliente,
} from './application/use-cases/consultar-saldos.use-case';
import { CorregirSaldos } from './application/use-cases/corregir.use-case';
import { ConsultarCatalogoDeVenta, GestionarTipos } from './application/use-cases/tipos.use-case';
import { VencerTiqueteras } from './application/use-cases/vencer.use-case';
import { VenderTiquetera } from './application/use-cases/vender.use-case';

/** Casos de uso del módulo, conectados con sus puertos (la aplicación no conoce NestJS). */
export const PROVEEDORES_TIQUETERAS: FactoryProvider[] = [
  {
    provide: GestionarTipos,
    useFactory: (tipos: TiposRepository, ids: GeneradorIds) => new GestionarTipos(tipos, ids),
    inject: [TIPOS_REPOSITORY, GENERADOR_IDS],
  },
  {
    provide: ConsultarCatalogoDeVenta,
    useFactory: (tipos: TiposRepository, ventas: VentasRepository) =>
      new ConsultarCatalogoDeVenta(tipos, ventas),
    inject: [TIPOS_REPOSITORY, VENTAS_REPOSITORY],
  },
  {
    provide: VenderTiquetera,
    useFactory: (
      ...[tipos, ventas, saldos, ids, reloj]: [
        TiposRepository,
        VentasRepository,
        SaldosRepository,
        GeneradorIds,
        Reloj,
      ]
    ) => new VenderTiquetera({ tipos, ventas, saldos, ids, reloj }),
    inject: [TIPOS_REPOSITORY, VENTAS_REPOSITORY, SALDOS_REPOSITORY, GENERADOR_IDS, RELOJ],
  },
  {
    provide: ConsultarSaldoDelCliente,
    useFactory: (saldos: SaldosRepository, reloj: Reloj) =>
      new ConsultarSaldoDelCliente(saldos, reloj),
    inject: [SALDOS_REPOSITORY, RELOJ],
  },
  {
    provide: ConsultarMisTiqueteras,
    useFactory: (saldos: SaldosRepository, reloj: Reloj) =>
      new ConsultarMisTiqueteras(saldos, reloj),
    inject: [SALDOS_REPOSITORY, RELOJ],
  },
  {
    provide: CorregirSaldos,
    useFactory: (
      ventas: VentasRepository,
      saldos: SaldosRepository,
      ids: GeneradorIds,
      reloj: Reloj,
    ) => new CorregirSaldos({ ventas, saldos, ids, reloj }),
    inject: [VENTAS_REPOSITORY, SALDOS_REPOSITORY, GENERADOR_IDS, RELOJ],
  },
  {
    provide: VencerTiqueteras,
    useFactory: (repo: VencimientoRepository, reloj: Reloj, observabilidad: Observabilidad) =>
      new VencerTiqueteras(repo, reloj, observabilidad),
    inject: [VENCIMIENTO_REPOSITORY, RELOJ, OBSERVABILIDAD],
  },
];
