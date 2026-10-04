import { describe, expect, it } from 'vitest';
import { formatearPesos } from './moneda';

describe('formatearPesos', () => {
  it('usa punto de miles y no muestra decimales', () => {
    expect(formatearPesos(330000)).toBe('$ 330.000');
  });

  it('redondea los centavos', () => {
    expect(formatearPesos(10999.6)).toBe('$ 11.000');
  });
});
