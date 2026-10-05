import { HorarioSeCruza } from '../../domain/errors/horario-se-cruza.error';
import { ReferenciaNoEncontrada } from '../../domain/errors/referencia-no-encontrada.error';
import { CambiarHorario } from './cambiar-horario.use-case';
import { CrearHorario } from './crear-horario.use-case';
import { HorariosEnMemoria } from './horarios-en-memoria.fake';
import { ListarHorarios } from './listar-horarios.use-case';
import { GestionarServicios } from './servicios.use-case';

describe('Horarios de servicio', () => {
  let repositorio: HorariosEnMemoria;
  let crear: CrearHorario;
  let cambiar: CambiarHorario;
  let contador: number;
  const ids = { siguiente: () => `id-${++contador}` };
  const almuerzo = {
    servicioId: 'almuerzo',
    sedeId: 'principal',
    dias: ['MONDAY'],
    horaInicio: '11:30',
    horaFin: '15:00',
  };

  beforeEach(() => {
    contador = 0;
    repositorio = new HorariosEnMemoria({ almuerzo: 'Almuerzo', cena: 'Cena' }, ['principal']);
    crear = new CrearHorario(repositorio, ids);
    cambiar = new CambiarHorario(repositorio, ids);
  });

  it('guarda el horario y lo devuelve', async () => {
    const [creado] = await crear.ejecutar(almuerzo);
    expect(creado).toEqual({
      id: 'id-1',
      servicioId: 'almuerzo',
      sedeId: 'principal',
      dia: 'MONDAY',
      horaInicio: '11:30',
      horaFin: '15:00',
      activo: true,
    });
  });

  it('copia el mismo horario a varios días en una sola vez', async () => {
    const creados = await crear.ejecutar({ ...almuerzo, dias: ['MONDAY', 'TUESDAY', 'MONDAY'] });
    expect(creados.map((h) => h.dia)).toEqual(['MONDAY', 'TUESDAY']);
  });

  it('si un día se cruza no guarda ninguno', async () => {
    await crear.ejecutar({ ...almuerzo, dias: ['TUESDAY'] });
    await expect(
      crear.ejecutar({
        ...almuerzo,
        dias: ['MONDAY', 'TUESDAY'],
        horaInicio: '14:00',
        horaFin: '16:00',
      }),
    ).rejects.toThrow(HorarioSeCruza);
    expect(repositorio.guardados).toHaveLength(1);
  });

  it('pide al menos un día', async () => {
    await expect(crear.ejecutar({ ...almuerzo, dias: [] })).rejects.toThrow('al menos un día');
  });

  it('exige que el servicio y la sede sean del negocio', async () => {
    await expect(crear.ejecutar({ ...almuerzo, servicioId: 'onces' })).rejects.toThrow(
      ReferenciaNoEncontrada,
    );
    await expect(crear.ejecutar({ ...almuerzo, sedeId: 'norte' })).rejects.toThrow('sede');
  });

  it('el listado muestra el nombre del servicio y la versión cambia', async () => {
    const listar = new ListarHorarios(repositorio);
    const antes = await listar.version();
    await crear.ejecutar(almuerzo);
    expect(await listar.ejecutar()).toEqual([
      expect.objectContaining({ id: 'id-1', servicioNombre: 'Almuerzo' }),
    ]);
    expect(await listar.version()).not.toBe(antes);
  });

  it('editar guarda un horario nuevo y cierra el anterior', async () => {
    await crear.ejecutar(almuerzo);
    const editado = await cambiar.editar('id-1', { horaInicio: '12:00', horaFin: '15:30' });
    expect(editado).toEqual(expect.objectContaining({ id: 'id-2', horaInicio: '12:00' }));
    expect(repositorio.cerrados).toEqual(['id-1']);
  });

  it('editar no deja cruzarse con otro servicio, pero sí con su propio horario', async () => {
    await crear.ejecutar(almuerzo);
    await crear.ejecutar({
      ...almuerzo,
      servicioId: 'cena',
      horaInicio: '18:00',
      horaFin: '21:00',
    });
    await expect(
      cambiar.editar('id-1', { horaInicio: '11:00', horaFin: '15:00' }),
    ).resolves.toBeTruthy();
    await expect(cambiar.editar('id-2', { horaInicio: '14:00', horaFin: '21:00' })).rejects.toThrow(
      HorarioSeCruza,
    );
  });

  it('un horario en pausa no se cruza y al reanudarlo se revisa otra vez', async () => {
    await crear.ejecutar(almuerzo);
    await cambiar.cambiarEstado('id-1', false);
    await crear.ejecutar({
      ...almuerzo,
      servicioId: 'cena',
      horaInicio: '14:00',
      horaFin: '16:00',
    });
    await expect(cambiar.cambiarEstado('id-1', true)).rejects.toThrow(HorarioSeCruza);
  });

  it('un horario que no existe se informa con calma', async () => {
    await expect(cambiar.cambiarEstado('nada', false)).rejects.toThrow('No encontramos');
  });

  it('crea servicios con nombre limpio', async () => {
    const servicios = new GestionarServicios(repositorio, ids);
    await expect(servicios.crear('  Onces   de la tarde ')).resolves.toEqual({
      id: 'id-1',
      nombre: 'Onces de la tarde',
    });
    await expect(servicios.crear('x')).rejects.toThrow('de 2 a 60');
  });
});
