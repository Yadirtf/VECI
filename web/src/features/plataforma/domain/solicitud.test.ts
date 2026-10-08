import { documentoLegible, problemaConMotivo } from './solicitud';

describe('reglas de la consola VECI', () => {
  it('pide un motivo de rechazo que la persona entienda', () => {
    expect(problemaConMotivo('  corto ')).toMatch('10 letras');
    expect(problemaConMotivo('El NIT no corresponde al negocio')).toBeNull();
  });

  it('muestra el NIT con su dígito de verificación aparte', () => {
    expect(documentoLegible('NIT', '8001972684')).toBe('NIT 800.197.268-4');
    expect(documentoLegible('CC', '1124500321')).toBe('CC 1124500321');
  });
});
