import { asegurarPinTemporalPermitido } from './alcance-de-cuenta.rule';

describe('alcance de la cuenta para un PIN temporal', () => {
  const solo = { otrosNegociosComoPersonal: 0, esEquipoVeci: false };

  it('un negocio entrega el PIN de quien solo trabaja ahí', () => {
    expect(() => asegurarPinTemporalPermitido(solo, true)).not.toThrow();
  });

  it('un negocio no entrega el PIN de quien también trabaja en otro', () => {
    expect(() =>
      asegurarPinTemporalPermitido({ ...solo, otrosNegociosComoPersonal: 1 }, true),
    ).toThrow('otro negocio');
  });

  it('Soporte VECI sí restablece a quien trabaja en varios negocios', () => {
    expect(() =>
      asegurarPinTemporalPermitido({ ...solo, otrosNegociosComoPersonal: 2 }, false),
    ).not.toThrow();
  });

  it('nadie entrega por esta vía el PIN de una cuenta del equipo VECI', () => {
    const veci = { ...solo, esEquipoVeci: true };
    expect(() => asegurarPinTemporalPermitido(veci, true)).toThrow('equipo VECI');
    expect(() => asegurarPinTemporalPermitido(veci, false)).toThrow('Administración VECI');
  });
});
