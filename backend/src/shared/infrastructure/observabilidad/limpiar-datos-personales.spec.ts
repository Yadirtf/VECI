import { limpiarDatosPersonales } from './limpiar-datos-personales';

describe('limpiarDatosPersonales', () => {
  it('conserva la ruta sin consulta y el método', () => {
    const evento = limpiarDatosPersonales({
      request: { url: 'https://api.veci.co/clientes?documento=1124000003', method: 'GET' },
    });
    expect(evento.request).toEqual({ url: 'https://api.veci.co/clientes', method: 'GET' });
  });

  it('quita cuerpo, cabeceras, cookies, usuario y datos extra', () => {
    const evento = limpiarDatosPersonales({
      request: {
        url: '/x',
        data: { celular: '+573100000003' },
        headers: { authorization: 'Bearer t' },
        cookies: { s: '1' },
      },
      user: { ip_address: '1.2.3.4' },
      extra: { documento: '1124000003' },
    });
    expect(JSON.stringify(evento)).not.toMatch(/573100000003|Bearer|1\.2\.3\.4|1124000003/);
  });
});
