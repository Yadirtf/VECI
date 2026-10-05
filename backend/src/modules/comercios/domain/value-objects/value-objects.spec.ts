import { digitoVerificacion, DocumentoNegocio } from './documento-negocio.vo';
import { Logo } from './logo.vo';
import { NombreNegocio } from './nombre-negocio.vo';

describe('DocumentoNegocio', () => {
  it('calcula el dígito de verificación de la DIAN', () => {
    expect(digitoVerificacion('800197268')).toBe(4);
    expect(digitoVerificacion('900123456')).toBe(8);
  });

  it('completa el NIT cuando la persona escribe solo la base', () => {
    const nit = DocumentoNegocio.de('NIT', '800.197.268');
    expect(nit.numero).toBe('8001972684');
    expect(nit.legible).toBe('800.197.268-4');
  });

  it('acepta el NIT con su dígito, con o sin guion', () => {
    expect(DocumentoNegocio.de('NIT', '800197268-4').numero).toBe('8001972684');
    expect(DocumentoNegocio.de('NIT', '8001972684').numero).toBe('8001972684');
  });

  it('dice cuál es el dígito correcto si lo escribieron mal', () => {
    expect(() => DocumentoNegocio.de('NIT', '800197268-5')).toThrow(
      'el dígito de verificación es 4',
    );
  });

  it('valida la cédula y rechaza otros tipos', () => {
    expect(DocumentoNegocio.de('CC', '1124 500 001').numero).toBe('1124500001');
    expect(() => DocumentoNegocio.de('CC', '123')).toThrow('de 6 a 10');
    expect(() => DocumentoNegocio.de('TI', '1234567890')).toThrow('NIT o con cédula');
  });
});

describe('NombreNegocio', () => {
  it('limpia espacios y arma el enlace sin tildes', () => {
    const nombre = NombreNegocio.de('  Panadería   El Trigal ');
    expect(nombre.valor).toBe('Panadería El Trigal');
    expect(nombre.slug).toBe('panaderia-el-trigal');
  });

  it('rechaza nombres muy cortos y da un enlace aunque no haya letras', () => {
    expect(() => NombreNegocio.de('ab')).toThrow('de 3 a 120');
    expect(NombreNegocio.de('¡¡¡!!!').slug).toBe('negocio');
  });
});

describe('Logo', () => {
  it('solo acepta direcciones https', () => {
    expect(Logo.de('https://lavecina.co/logo.png').url).toBe('https://lavecina.co/logo.png');
    expect(() => Logo.de('http://lavecina.co/logo.png')).toThrow('https');
    expect(() => Logo.de('logo')).toThrow('no abre');
  });
});
