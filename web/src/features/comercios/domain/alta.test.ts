import { aDatosAlta, BORRADOR_VACIO, inicialDe, problemaEnPaso, serviciosEnPalabras } from './alta';
import { digitoVerificacion, nitLegible } from './nit';

describe('NIT', () => {
  it('calcula el dígito de verificación como la DIAN', () => {
    expect(digitoVerificacion('800197268')).toBe(4);
    expect(nitLegible('8001972684')).toBe('800.197.268-4');
  });
});

describe('Alta conversada', () => {
  const borrador = {
    ...BORRADOR_VACIO,
    nombre: ' Restaurante La Vecina ',
    tipoNegocio: 'RESTAURANT',
    documento: '800.197.268',
    celular: '310 000 0101',
  };

  it('cada paso dice qué falta con palabras del negocio', () => {
    expect(problemaEnPaso('NOMBRE', BORRADOR_VACIO)).toContain('Mínimo 3 letras');
    expect(problemaEnPaso('TIPO', BORRADOR_VACIO)).toContain('Toca');
    expect(problemaEnPaso('DOCUMENTO', { ...borrador, documento: '123' })).toContain('9 números');
    expect(problemaEnPaso('CONTACTO', { ...borrador, celular: '210' })).toContain('empieza por 3');
    expect(problemaEnPaso('CONTACTO', { ...borrador, correo: 'hola@' })).toContain('correo');
    expect(problemaEnPaso('DOCUMENTO', borrador)).toBeNull();
  });

  it('arma los datos con el NIT completo y el celular limpio', () => {
    expect(aDatosAlta(borrador)).toEqual({
      nombre: 'Restaurante La Vecina',
      tipoNegocio: 'RESTAURANT',
      tipoDocumento: 'NIT',
      numeroDocumento: '8001972684',
      celular: '3100000101',
      correo: null,
      municipioId: null,
      direccion: null,
    });
  });

  it('cuenta los servicios y saca la inicial del sello', () => {
    const tipo = {
      codigo: 'RESTAURANT',
      nombre: 'Restaurante',
      servicios: ['Desayuno', 'Almuerzo', 'Cena'].map((nombre) => ({
        nombre,
        horaInicio: '',
        horaFin: '',
      })),
    };
    expect(serviciosEnPalabras(tipo)).toBe('Desayuno, Almuerzo y Cena');
    expect(inicialDe('Restaurante La Vecina')).toBe('V');
    expect(inicialDe('Doña Rosa')).toBe('D');
  });
});
