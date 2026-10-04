import { CambiarEstadoCajero } from './cambiar-estado-cajero.use-case';
import { InvitarCajero } from './invitar-cajero.use-case';
import { ListarPersonal } from './listar-personal.use-case';
import { PersonalEnMemoria } from './personal-en-memoria.fake';
import { RestablecerPinCajero } from './restablecer-pin-cajero.use-case';

describe('Gestionar cajeros (HU-02-04, HU-02-05)', () => {
  let db: PersonalEnMemoria;
  let invitar: InvitarCajero;
  const actor = { usuarioId: 'dueno', comercioId: 'c1' };
  const ana = {
    celular: '312 456 7890',
    nombres: 'Ana',
    apellidos: null,
    tipoDocumento: 'CC',
    numeroDocumento: '1124500777',
  };
  const dueno = {
    membresiaId: 'm-dueno',
    usuarioId: 'dueno',
    nombre: 'Marta',
    celular: null,
    estado: 'ACTIVE' as const,
    roles: ['OWNER'],
  };

  beforeEach(() => {
    db = new PersonalEnMemoria();
    db.miembros.push(dueno);
    invitar = new InvitarCajero({
      personal: db,
      pinTemporal: db.pinTemporal,
      auditoria: db.bitacora,
    });
  });

  it('invita a alguien nuevo con PIN temporal y lo audita', async () => {
    const resultado = await invitar.ejecutar(actor, ana);
    expect(resultado.pinTemporal).toBe('730284');
    expect(db.invitaciones[0]).toMatchObject({
      usuarioId: null,
      persona: { celular: '+573124567890' },
    });
    expect(db.pines[0]).toMatchObject({ motivo: 'INVITACION', comercioId: 'c1' });
    expect(db.auditoria.map((a) => a.accion)).toEqual(['MEMBERSHIP_CHANGED', 'ROLE_GRANTED']);
  });

  it('a quien ya tiene cuenta con PIN propio no le da PIN temporal', async () => {
    db.usuarios.set('+573124567890', { usuarioId: 'u-ana', tienePinPropio: true });
    await expect(invitar.ejecutar(actor, ana)).resolves.toMatchObject({ pinTemporal: null });
    expect(db.invitaciones[0].usuarioId).toBe('u-ana');
  });

  it('no duplica, respeta el plan y detecta cédulas con otro celular', async () => {
    await invitar.ejecutar(actor, ana);
    db.usuarios.set('+573124567890', {
      usuarioId: db.miembros[1].usuarioId,
      tienePinPropio: false,
    });
    await expect(invitar.ejecutar(actor, ana)).rejects.toMatchObject({
      codigo: 'YA_ES_DEL_EQUIPO',
    });
    db.documentos.set('CC:1124500888', { personaId: 'p', usuarioId: 'u-otro' });
    const pedro = { ...ana, celular: '3110000000', numeroDocumento: '1124500888' };
    await expect(invitar.ejecutar(actor, pedro)).rejects.toMatchObject({
      codigo: 'CELULAR_NO_COINCIDE',
    });
    db.limite = 1;
    await expect(invitar.ejecutar(actor, { ...pedro, numeroDocumento: '1' })).rejects.toMatchObject(
      {
        codigo: 'LIMITE_DE_CAJEROS',
      },
    );
  });

  it('suspende, reactiva, retira y vuelve a invitar a un cajero', async () => {
    const { membresiaId } = await invitar.ejecutar(actor, ana);
    const cambiar = new CambiarEstadoCajero(db, db.bitacora);
    await expect(cambiar.ejecutar(actor, membresiaId, 'REACTIVAR')).rejects.toThrow('suspendido');
    await cambiar.ejecutar(actor, membresiaId, 'SUSPENDER');
    await expect(cambiar.ejecutar(actor, membresiaId, 'REACTIVAR')).resolves.toMatchObject({
      estado: 'ACTIVE',
    });
    await cambiar.ejecutar(actor, membresiaId, 'RETIRAR');
    expect(await new ListarPersonal(db).ejecutar()).toHaveLength(1);
    db.usuarios.set('+573124567890', { usuarioId: db.miembros[1].usuarioId, tienePinPropio: true });
    await invitar.ejecutar(actor, ana);
    expect(db.invitaciones[1].membresiaRetirada).toBe(membresiaId);
    expect(db.auditoria.filter((a) => a.accion === 'MEMBERSHIP_CHANGED')).toHaveLength(5);
  });

  it('no gestiona al propietario ni a uno mismo, ni a quien no existe', async () => {
    const cambiar = new CambiarEstadoCajero(db, db.bitacora);
    await expect(
      cambiar.ejecutar({ ...actor, usuarioId: 'otro' }, 'm-dueno', 'SUSPENDER'),
    ).rejects.toThrow('propietario');
    await expect(cambiar.ejecutar(actor, 'm-dueno', 'SUSPENDER')).rejects.toThrow('propia cuenta');
    await expect(cambiar.ejecutar(actor, 'nadie', 'SUSPENDER')).rejects.toMatchObject({
      codigo: 'MIEMBRO_NO_ENCONTRADO',
    });
  });

  it('el propietario restablece el PIN de un cajero', async () => {
    const { membresiaId } = await invitar.ejecutar(actor, ana);
    const restablecer = new RestablecerPinCajero(db, db.pinTemporal);
    await expect(restablecer.ejecutar(actor, membresiaId)).resolves.toEqual({
      pinTemporal: '730284',
    });
    expect(db.pines.at(-1)).toMatchObject({ motivo: 'RESET_BY_OWNER', porUsuarioId: 'dueno' });
    await expect(restablecer.ejecutar(actor, 'nadie')).rejects.toMatchObject({
      codigo: 'MIEMBRO_NO_ENCONTRADO',
    });
  });
});
