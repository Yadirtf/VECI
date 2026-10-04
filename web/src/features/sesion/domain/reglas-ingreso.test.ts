import { describe, expect, it } from 'vitest';
import {
  comercioInicial,
  negociosDelPanel,
  problemaConCelular,
  problemaConPin,
  soloDigitosDelCelular,
} from './reglas-ingreso';
import type { Espacio } from './sesion';

const espacio = (comercioId: string, roles: string[]): Espacio => ({
  comercioId,
  nombre: `Negocio ${comercioId}`,
  tipoNegocio: 'RESTAURANT',
  roles,
  invitacionPendiente: false,
});

describe('reglas de ingreso del panel', () => {
  it('acepta el celular con espacios o con +57', () => {
    expect(soloDigitosDelCelular('+57 310 000 0101')).toBe('3100000101');
    expect(problemaConCelular('310-000-0101')).toBeNull();
  });

  it('explica cómo debe ser el celular', () => {
    expect(problemaConCelular('')).toMatch(/Escribe/);
    expect(problemaConCelular('2100000101')).toMatch(/empieza por 3/);
  });

  it('el PIN son 6 números', () => {
    expect(problemaConPin('246813')).toBeNull();
    expect(problemaConPin('2468')).toMatch(/6 números/);
  });

  it('el panel muestra solo los negocios que la persona administra', () => {
    const negocios = negociosDelPanel([espacio('a', ['OWNER']), espacio('b', ['CASHIER'])]);
    expect(negocios.map((n) => n.comercioId)).toEqual(['a']);
  });

  it('arranca con el negocio guardado, o con el único que tiene', () => {
    const negocios = [espacio('a', ['OWNER']), espacio('b', ['OWNER'])];
    expect(comercioInicial(negocios, 'b')).toBe('b');
    expect(comercioInicial(negocios, 'zzz')).toBeNull();
    expect(comercioInicial([negocios[0]], null)).toBe('a');
  });
});
