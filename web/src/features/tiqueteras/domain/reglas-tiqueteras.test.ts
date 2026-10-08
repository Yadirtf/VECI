import { describe, expect, it } from 'vitest';
import { tipo, tiquetera } from '../pruebas';
import {
  armarPago,
  cantidad,
  diaLegible,
  ordenarPizarra,
  problemaDeCorreccion,
  problemaDelAjuste,
  problemaDelTipo,
} from './reglas-tiqueteras';

const datos = {
  nombre: '20 almuerzos',
  unidad: 'LUNCH',
  unidades: 20,
  precio: 220000,
  vigenciaDias: 30,
};
const transferencia = {
  codigo: 'BANK_TRANSFER',
  nombre: 'Transferencia',
  necesitaCanal: true,
  canales: [{ codigo: 'NEQUI', nombre: 'Nequi' }],
};

describe('reglas de tiqueteras', () => {
  it('revisa el formulario de la pizarra con los límites de la API', () => {
    expect(problemaDelTipo(datos)).toBeNull();
    expect(problemaDelTipo({ ...datos, nombre: ' x ' })).toMatch(/nombre/);
    expect(problemaDelTipo({ ...datos, unidad: '' })).toMatch(/descuenta/);
    expect(problemaDelTipo({ ...datos, unidades: 0 })).toMatch(/cantidad/);
    expect(problemaDelTipo({ ...datos, precio: 500 })).toMatch(/precio/);
    expect(problemaDelTipo({ ...datos, vigenciaDias: 1.5 })).toMatch(/vigencia/);
  });

  it('en la pizarra va primero lo que se vende', () => {
    const guardado = tipo({ tipoId: 'a', nombre: 'Almuerzo', estado: 'INACTIVE' });
    const cafe = tipo({ tipoId: 'c', nombre: 'Café' });
    const bandeja = tipo({ tipoId: 'b', nombre: 'Bandeja' });
    expect(ordenarPizarra([guardado, cafe, bandeja]).map((t) => t.tipoId)).toEqual(['b', 'c', 'a']);
  });

  it('el pago por transferencia pide canal; el efectivo no', () => {
    const efectivo = { codigo: 'CASH', nombre: 'Efectivo', necesitaCanal: false, canales: [] };
    expect(armarPago(efectivo, 'NEQUI', 'x')).toEqual({
      medio: 'CASH',
      canal: null,
      referencia: null,
    });
    expect(armarPago(transferencia, '', '')).toMatch(/Nequi/);
    expect(armarPago(transferencia, 'NEQUI', ' M1 ')).toEqual({
      medio: 'BANK_TRANSFER',
      canal: 'NEQUI',
      referencia: 'M1',
    });
    expect(armarPago(undefined, '', '')).toMatch(/pagó/);
  });

  it('una corrección lleva motivo y, con «Otro», nota', () => {
    expect(problemaDeCorreccion({ motivo: '', nota: null })).toMatch(/motivo/);
    expect(problemaDeCorreccion({ motivo: 'OTHER', nota: '  ' })).toMatch(/nota/);
    expect(problemaDeCorreccion({ motivo: 'COURTESY', nota: null })).toBeNull();
  });

  it('el ajuste no deja el saldo en negativo ni toca lo vencido', () => {
    expect(problemaDelAjuste(tiquetera(), 0)).toMatch(/suma/);
    expect(problemaDelAjuste(tiquetera(), -15)).toBe('Solo le quedan 14 almuerzos.');
    expect(problemaDelAjuste(tiquetera({ estado: 'EXPIRED' }), 1)).toMatch(/vencida/);
    expect(problemaDelAjuste(tiquetera(), -2)).toBeNull();
  });

  it('habla en unidades y fechas de vecino', () => {
    expect(cantidad(1, tipo().unidad)).toBe('1 almuerzo');
    expect(cantidad(-2, tipo().unidad)).toBe('-2 almuerzos');
    expect(diaLegible('2026-11-06')).toBe('6 nov 2026');
  });
});
