import { leerConfiguracion } from './configuracion';

describe('leerConfiguracion', () => {
  it('usa valores de desarrollo cuando no hay variables', () => {
    const config = leerConfiguracion({});
    expect(config.entorno).toBe('desarrollo');
    expect(config.documentacionActiva).toBe(true);
    expect(config.identidadDesarrollo).toBe(true);
    expect(config.puerto).toBe(3000);
  });

  it('en producción apaga /docs y la identidad de desarrollo aunque se pidan', () => {
    const config = leerConfiguracion({
      VECI_ENTORNO: 'produccion',
      DATABASE_APP_URL: 'postgresql://x',
      VECI_DOCS: 'true',
      VECI_IDENTIDAD_DESARROLLO: 'true',
    });
    expect(config.documentacionActiva).toBe(false);
    expect(config.identidadDesarrollo).toBe(false);
  });

  it('exige la URL de la base en staging y producción', () => {
    expect(() => leerConfiguracion({ VECI_ENTORNO: 'staging' })).toThrow('DATABASE_APP_URL');
  });

  it('arma la URL de veci_api con la base del dueño y la clave de la API', () => {
    const config = leerConfiguracion({
      VECI_ENTORNO: 'staging',
      DATABASE_URL: 'postgresql://dueno:secreta@db.neon.tech/veci?sslmode=require',
      VECI_API_DB_PASSWORD: 'clave-api',
    });
    expect(config.databaseAppUrl).toBe(
      'postgresql://veci_api:clave-api@db.neon.tech/veci?sslmode=require',
    );
  });

  it('prefiere DATABASE_APP_URL cuando está definida', () => {
    const config = leerConfiguracion({
      DATABASE_APP_URL: 'postgresql://propia',
      DATABASE_URL: 'postgresql://dueno:x@h/veci',
      VECI_API_DB_PASSWORD: 'y',
    });
    expect(config.databaseAppUrl).toBe('postgresql://propia');
  });

  it('rechaza un entorno desconocido', () => {
    expect(() => leerConfiguracion({ VECI_ENTORNO: 'prod' })).toThrow('VECI_ENTORNO');
  });

  it('separa los orígenes permitidos por coma', () => {
    const config = leerConfiguracion({ VECI_ORIGENES: 'https://a.co,https://b.co' });
    expect(config.origenesPermitidos).toEqual(['https://a.co', 'https://b.co']);
  });
});
