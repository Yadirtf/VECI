import { EmitirPinTemporal } from '../../../autenticacion';
import { CuentasSoporteRepository } from '../puertos/cuentas-soporte.repository';
import { RestablecerPinCliente } from './restablecer-pin-cliente.use-case';

describe('RestablecerPinCliente', () => {
  const cuentas: CuentasSoporteRepository = {
    buscarPorCelular: async (celular) =>
      celular === '+573100000103' ? { usuarioId: 'u3', personaId: 'p3' } : null,
    buscarPorDocumento: async (_tipo, numero) =>
      numero === '1124500003' ? { personaId: 'p3', nombreEnmascarado: 'Luz Marina C.' } : null,
  };
  const emitidos: unknown[] = [];
  const pinTemporal = {
    ejecutar: async (entrada: unknown) => {
      emitidos.push(entrada);
      return '730284';
    },
  } as unknown as EmitirPinTemporal;
  const caso = new RestablecerPinCliente(cuentas, pinTemporal);
  const entrada = {
    soporteUsuarioId: 's1',
    celular: '310 000 0103',
    tipoDocumento: 'CC',
    numeroDocumento: '1124500003',
  };

  it('restablece cuando el documento es el de la cuenta', async () => {
    await expect(caso.ejecutar(entrada)).resolves.toEqual({
      pinTemporal: '730284',
      nombre: 'Luz Marina C.',
    });
    expect(emitidos).toEqual([
      { usuarioId: 'u3', motivo: 'RESET_BY_SUPPORT', porUsuarioId: 's1', comercioId: null },
    ]);
  });

  it('no restablece si el documento no coincide o el celular no existe', async () => {
    await expect(caso.ejecutar({ ...entrada, numeroDocumento: '999' })).rejects.toMatchObject({
      codigo: 'DOCUMENTO_NO_COINCIDE',
    });
    await expect(caso.ejecutar({ ...entrada, celular: '3209999999' })).rejects.toMatchObject({
      codigo: 'CUENTA_NO_ENCONTRADA',
    });
  });
});
