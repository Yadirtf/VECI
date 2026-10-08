import { Tiquetera } from '../entities/tiquetera';
import { MedioDePago } from '../entities/venta';
import { validarAjuste, validarMotivo } from './correccion.rule';
import { validarPago } from './pago.rule';
import { precioPorUnidad, validarTipo } from './reglas-tipo.rule';
import { ordenDeConsumo, repartirConsumo, saldosPorUnidad } from './saldo.rule';
import { calcularVencimiento, fechaLocal, ultimoDiaDeUso } from './vigencia.rule';

const BOGOTA = 'America/Bogota';
const ahora = new Date('2026-10-08T15:00:00Z');
const almuerzo = { codigo: 'LUNCH', singular: 'almuerzo', plural: 'almuerzos' };
const desayuno = { codigo: 'BREAKFAST', singular: 'desayuno', plural: 'desayunos' };

function tiquetera(id: string, cambios: Partial<Tiquetera> = {}): Tiquetera {
  return {
    tiqueteraId: id,
    clienteId: 'c',
    ventaId: `v-${id}`,
    tipoId: 't',
    nombre: '20 almuerzos',
    unidad: almuerzo,
    compradas: 20,
    saldo: 20,
    estado: 'ACTIVE',
    compradaEn: new Date('2026-10-01T15:00:00Z'),
    venceEn: new Date('2026-10-31T05:00:00Z'),
    precio: 220000,
    ...cambios,
  };
}

describe('Tipos de tiquetera (HU-05-01)', () => {
  const base = {
    nombre: '  20   almuerzos ',
    unidad: 'LUNCH',
    unidades: 20,
    precio: 220000,
    vigenciaDias: 30,
  };

  it('limpia el nombre y acepta un paquete normal', () => {
    expect(validarTipo(base)).toEqual({ ...base, nombre: '20 almuerzos' });
    expect(precioPorUnidad(220000, 20)).toBe(11000);
  });

  it.each([
    [{ nombre: 'ab' }, 'nombre'],
    [{ unidades: 0 }, 'unidades'],
    [{ unidades: 2.5 }, 'unidades'],
    [{ precio: 999 }, 'precio'],
    [{ precio: 1500.5 }, 'centavos'],
    [{ vigenciaDias: 400 }, 'vigencia'],
    [{ unidad: 'almuerzo' }, 'código'],
  ])('rechaza %j', (cambio, texto) => {
    expect(() => validarTipo({ ...base, ...cambio })).toThrow(new RegExp(texto, 'i'));
  });
});

describe('Vigencia en la fecha del negocio (HU-05-04)', () => {
  it('el día de compra cuenta y vence a la medianoche después del último día', () => {
    const compra = new Date('2026-10-08T22:30:00Z'); // 5:30 p. m. en Bogotá
    const vence = calcularVencimiento(compra, 30, BOGOTA);
    expect(vence.toISOString()).toBe('2026-11-07T05:00:00.000Z');
    expect(ultimoDiaDeUso(vence, BOGOTA)).toBe('2026-11-06');
  });

  it('una compra de noche en Colombia usa la fecha local, no la del servidor', () => {
    const compra = new Date('2026-10-09T03:00:00Z'); // 10 p. m. del 8 en Bogotá
    expect(fechaLocal(compra, BOGOTA)).toBe('2026-10-08');
    expect(ultimoDiaDeUso(calcularVencimiento(compra, 1, BOGOTA), BOGOTA)).toBe('2026-10-08');
  });

  it('respeta zonas con horario de verano', () => {
    const compra = new Date('2026-03-07T18:00:00Z');
    const vence = calcularVencimiento(compra, 2, 'America/New_York');
    expect(vence.toISOString()).toBe('2026-03-09T04:00:00.000Z');
  });
});

describe('Varias tiqueteras activas (HU-05-03)', () => {
  const vieja = tiquetera('a', { saldo: 1, venceEn: new Date('2026-10-20T05:00:00Z') });
  const nueva = tiquetera('b', { saldo: 20, venceEn: new Date('2026-11-07T05:00:00Z') });
  const vencida = tiquetera('c', { saldo: 5, venceEn: new Date('2026-10-08T05:00:00Z') });
  const anulada = tiquetera('d', { saldo: 3, estado: 'VOIDED' });
  const desayunos = tiquetera('e', { unidad: desayuno, saldo: 10 });

  it('se gasta primero la que vence antes y no cuentan vencidas ni anuladas', () => {
    expect(
      ordenDeConsumo([nueva, vencida, anulada, vieja], ahora).map((t) => t.tiqueteraId),
    ).toEqual(['a', 'b']);
  });

  it('el saldo es la suma de las vigentes, sin mezclar unidades', () => {
    expect(saldosPorUnidad([nueva, vencida, vieja, anulada, desayunos], ahora)).toEqual([
      { unidad: almuerzo, disponibles: 21, proximoVencimiento: vieja.venceEn, tiqueteras: 2 },
      { unidad: desayuno, disponibles: 10, proximoVencimiento: desayunos.venceEn, tiqueteras: 1 },
    ]);
  });

  it('un consumo de 2 con 1 en la primera sigue con la siguiente', () => {
    expect(repartirConsumo([nueva, vieja], 2, ahora)).toEqual([
      { tiqueteraId: 'a', unidades: 1 },
      { tiqueteraId: 'b', unidades: 1 },
    ]);
    expect(repartirConsumo([nueva, vieja], 1, ahora)).toEqual([{ tiqueteraId: 'a', unidades: 1 }]);
  });

  it('sin saldo suficiente no reparte', () => {
    expect(() => repartirConsumo([vieja], 3, ahora)).toThrow('Solo le quedan 1');
    expect(() => repartirConsumo([vencida], 1, ahora)).toThrow('No le quedan');
  });
});

describe('Medio de pago (HU-05-02)', () => {
  const catalogo: MedioDePago[] = [
    { codigo: 'CASH', nombre: 'Efectivo', necesitaCanal: false, canales: [] },
    {
      codigo: 'BANK_TRANSFER',
      nombre: 'Transferencia',
      necesitaCanal: true,
      canales: [
        { codigo: 'NEQUI', nombre: 'Nequi' },
        { codigo: 'DAVIPLATA', nombre: 'Daviplata' },
      ],
    },
  ];

  it('efectivo no lleva canal ni referencia', () => {
    expect(validarPago({ medio: 'CASH', canal: null, referencia: 'x' }, catalogo)).toEqual({
      medio: 'CASH',
      canal: null,
      referencia: null,
    });
    expect(() =>
      validarPago({ medio: 'CASH', canal: 'NEQUI', referencia: null }, catalogo),
    ).toThrow('no lleva canal');
  });

  it('la transferencia pide canal y la referencia es opcional', () => {
    const pago = { medio: 'BANK_TRANSFER', canal: 'NEQUI', referencia: '  M123 ' };
    expect(validarPago(pago, catalogo)).toEqual({ ...pago, referencia: 'M123' });
    expect(validarPago({ ...pago, referencia: '' }, catalogo).referencia).toBeNull();
    expect(() => validarPago({ ...pago, canal: null }, catalogo)).toThrow('Nequi, Daviplata');
    expect(() => validarPago({ ...pago, referencia: 'x'.repeat(61) }, catalogo)).toThrow('larga');
    expect(() => validarPago({ ...pago, medio: 'BITCOIN' }, catalogo)).toThrow('no se recibe');
  });
});

describe('Anular y ajustar (HU-05-05)', () => {
  const motivos = [
    { codigo: 'DATA_ENTRY_ERROR', nombre: 'Error al registrar' },
    { codigo: 'OTHER', nombre: 'Otro' },
  ];

  it('el motivo es obligatorio y con "Otro" también la nota', () => {
    expect(validarMotivo('DATA_ENTRY_ERROR', '  ', motivos)).toEqual({
      codigo: 'DATA_ENTRY_ERROR',
      nota: null,
    });
    expect(() => validarMotivo('', null, motivos)).toThrow('motivo');
    expect(() => validarMotivo('OTHER', ' ', motivos)).toThrow('qué pasó');
    expect(() => validarMotivo('OTHER', 'x'.repeat(501), motivos)).toThrow('larga');
  });

  it('suma o quita sin dejar la tiquetera en negativo', () => {
    const t = tiquetera('a', { saldo: 3 });
    expect(validarAjuste(t, -3, ahora)).toBe(-3);
    expect(validarAjuste(tiquetera('b', { saldo: 0, estado: 'DEPLETED' }), 2, ahora)).toBe(2);
    expect(() => validarAjuste(t, -4, ahora)).toThrow('Solo le quedan 3');
    expect(() => validarAjuste(t, 0, ahora)).toThrow('ajuste va de 1');
    expect(() => validarAjuste(t, 1.5, ahora)).toThrow('ajuste va de 1');
  });

  it('no se ajusta una vencida ni una anulada', () => {
    const vencida = tiquetera('a', { venceEn: new Date('2026-10-08T05:00:00Z') });
    expect(() => validarAjuste(vencida, 1, ahora)).toThrow('ya venció');
    expect(() => validarAjuste(tiquetera('b', { estado: 'VOIDED' }), 1, ahora)).toThrow('anulada');
  });
});
