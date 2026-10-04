import { createHmac } from 'node:crypto';
import { FirmadorHs256 } from './firmador-hs256';

describe('FirmadorHs256', () => {
  let ahora = new Date('2026-10-05T12:00:00Z');
  const reloj = { ahora: () => ahora };
  const firmador = new FirmadorHs256('secreto-de-pruebas-con-32-caracteres!', reloj);

  beforeEach(() => {
    ahora = new Date('2026-10-05T12:00:00Z');
  });

  it('verifica lo que firma y conserva la carga', () => {
    const token = firmador.firmar({ sub: 'u1', typ: 'acceso' }, 900);
    const resultado = firmador.verificar(token);
    expect(resultado).toMatchObject({ estado: 'valido', carga: { sub: 'u1', typ: 'acceso' } });
  });

  it('marca como vencido un token pasado su tiempo', () => {
    const token = firmador.firmar({ sub: 'u1' }, 900);
    ahora = new Date('2026-10-05T12:15:00Z');
    expect(firmador.verificar(token)).toEqual({ estado: 'vencido' });
  });

  it('rechaza un token con la carga alterada', () => {
    const [cabecera, , firma] = firmador.firmar({ sub: 'u1' }, 900).split('.');
    const otra = Buffer.from(JSON.stringify({ sub: 'admin', exp: 9e9 })).toString('base64url');
    expect(firmador.verificar(`${cabecera}.${otra}.${firma}`)).toEqual({ estado: 'invalido' });
  });

  it('rechaza el algoritmo "none" y tokens de otro secreto', () => {
    const ninguno = Buffer.from('{"alg":"none","typ":"JWT"}').toString('base64url');
    const carga = Buffer.from('{"sub":"u1","exp":9999999999}').toString('base64url');
    expect(firmador.verificar(`${ninguno}.${carga}.`)).toEqual({ estado: 'invalido' });
    const ajeno = new FirmadorHs256('otro-secreto-de-pruebas-con-32-caracteres', reloj);
    expect(firmador.verificar(ajeno.firmar({ sub: 'u1' }, 900))).toEqual({ estado: 'invalido' });
  });

  it('rechaza basura y cargas sin vencimiento', () => {
    expect(firmador.verificar('no-es-un-token')).toEqual({ estado: 'invalido' });
    const [cabecera] = firmador.firmar({}, 1).split('.');
    const carga = Buffer.from('{"sub":"u1"}').toString('base64url');
    const firma = createHmac('sha256', 'secreto-de-pruebas-con-32-caracteres!')
      .update(`${cabecera}.${carga}`)
      .digest('base64url');
    expect(firmador.verificar(`${cabecera}.${carga}.${firma}`)).toEqual({ estado: 'invalido' });
  });
});
