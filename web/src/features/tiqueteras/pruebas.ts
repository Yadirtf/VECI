import type { EstadoDeCuenta, TipoDeTiquetera, Tiquetera } from './domain/tiquetera';

// Datos de ejemplo para las pruebas de la funcionalidad.
export const almuerzo = { codigo: 'LUNCH', singular: 'almuerzo', plural: 'almuerzos' };

export const tipo = (cambios: Partial<TipoDeTiquetera> = {}): TipoDeTiquetera => ({
  tipoId: 't1',
  nombre: '20 almuerzos',
  unidad: almuerzo,
  unidades: 20,
  precio: 220000,
  precioPorUnidad: 11000,
  vigenciaDias: 30,
  estado: 'ACTIVE',
  vendidas: 0,
  vigentes: 0,
  ...cambios,
});

export const tiquetera = (cambios: Partial<Tiquetera> = {}): Tiquetera => ({
  tiqueteraId: 'q1',
  ventaId: 'v1',
  nombre: '20 almuerzos',
  unidad: almuerzo,
  compradas: 20,
  saldo: 14,
  estado: 'ACTIVE',
  compradaEn: new Date('2026-10-08T15:00:00Z'),
  ultimoDia: '2026-11-06',
  vigente: true,
  turno: 1,
  precio: 220000,
  ...cambios,
});

export const cuenta = (cambios: Partial<EstadoDeCuenta> = {}): EstadoDeCuenta => ({
  clienteId: 'c1',
  saldos: [{ unidad: almuerzo, disponibles: 14, ultimoDia: '2026-11-06', tiqueteras: 1 }],
  tiqueteras: [tiquetera()],
  movimientos: [
    {
      eventoId: 'e1',
      tipo: 'SALE',
      ocurridoEn: new Date('2026-10-08T15:00:00Z'),
      unidades: 20,
      tiquetera: '20 almuerzos',
      motivo: null,
      nota: null,
      quien: 'Ana Lucía',
    },
  ],
  ...cambios,
});
