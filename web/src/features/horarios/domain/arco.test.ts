import { aHora, aMinutos, AMANECER, ANOCHECER, minutoEn, puntoEn, tramo } from './arco';

const arco = { cx: 200, cy: 200, r: 150 };

describe('camino del sol', () => {
  it('convierte entre "HH:MM" y minutos', () => {
    expect(aMinutos('06:30')).toBe(390);
    expect(aHora(390)).toBe('06:30');
    expect(aHora(aMinutos('23:45'))).toBe('23:45');
  });

  it('el amanecer queda a la izquierda, el mediodía solar arriba y el anochecer a la derecha', () => {
    expect(puntoEn(arco, AMANECER).x).toBeCloseTo(50);
    expect(puntoEn(arco, ANOCHECER).x).toBeCloseTo(350);
    const medio = puntoEn(arco, (AMANECER + ANOCHECER) / 2);
    expect(medio.x).toBeCloseTo(200);
    expect(medio.y).toBeCloseTo(50);
  });

  it('un toque sobre el arco da la hora redondeada al cuarto de hora', () => {
    const p = puntoEn(arco, aMinutos('11:37'));
    expect(aHora(minutoEn(arco, p))).toBe('11:30');
  });

  it('debajo del horizonte cuenta el extremo más cercano', () => {
    expect(minutoEn(arco, { x: 10, y: 260 })).toBe(AMANECER);
    expect(minutoEn(arco, { x: 390, y: 260 })).toBe(ANOCHECER);
  });

  it('dibuja el tramo como un arco SVG', () => {
    expect(tramo(arco, AMANECER, ANOCHECER)).toBe('M 50.00 200.00 A 150 150 0 0 1 350.00 200.00');
  });
});
