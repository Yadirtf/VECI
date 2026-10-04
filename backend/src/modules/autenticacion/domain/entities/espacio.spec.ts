import { agruparEspacios, esPersonal } from './espacio';

describe('agruparEspacios', () => {
  it('une los roles de un mismo comercio y ordena por nombre', () => {
    const espacios = agruparEspacios([
      {
        comercioId: 'b',
        nombre: 'Panadería',
        tipoNegocio: 'BAKERY',
        rol: 'CUSTOMER',
        esInvitacion: false,
      },
      {
        comercioId: 'a',
        nombre: 'Asadero',
        tipoNegocio: 'RESTAURANT',
        rol: 'CASHIER',
        esInvitacion: true,
      },
      {
        comercioId: 'a',
        nombre: 'Asadero',
        tipoNegocio: 'RESTAURANT',
        rol: 'CUSTOMER',
        esInvitacion: false,
      },
    ]);
    expect(espacios).toEqual([
      {
        comercioId: 'a',
        nombre: 'Asadero',
        tipoNegocio: 'RESTAURANT',
        roles: ['CASHIER', 'CUSTOMER'],
        invitacionPendiente: true,
      },
      {
        comercioId: 'b',
        nombre: 'Panadería',
        tipoNegocio: 'BAKERY',
        roles: ['CUSTOMER'],
        invitacionPendiente: false,
      },
    ]);
    expect(espacios.map(esPersonal)).toEqual([true, false]);
  });
});
