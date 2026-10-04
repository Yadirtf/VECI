import { HorarioSeCruza } from '../../domain/errors/horario-se-cruza.error';
import { ReferenciaNoEncontrada } from '../../domain/errors/referencia-no-encontrada.error';
import { CrearHorario } from './crear-horario.use-case';
import { HorariosEnMemoria } from './horarios-en-memoria.fake';
import { ListarHorarios } from './listar-horarios.use-case';

describe('CrearHorario', () => {
  let repositorio: HorariosEnMemoria;
  let crear: CrearHorario;
  let contador: number;
  const almuerzo = {
    servicioId: 'almuerzo',
    sedeId: 'principal',
    dia: 'MONDAY',
    horaInicio: '11:30',
    horaFin: '15:00',
  };

  beforeEach(() => {
    contador = 0;
    repositorio = new HorariosEnMemoria({ almuerzo: 'Almuerzo' }, ['principal']);
    crear = new CrearHorario(repositorio, { siguiente: () => `id-${++contador}` });
  });

  it('guarda el horario y lo devuelve', async () => {
    await expect(crear.ejecutar(almuerzo)).resolves.toEqual({ id: 'id-1', ...almuerzo });
    expect(repositorio.guardados).toHaveLength(1);
  });

  it('no guarda un horario que se cruza con otro', async () => {
    await crear.ejecutar(almuerzo);
    await expect(
      crear.ejecutar({ ...almuerzo, horaInicio: '14:00', horaFin: '16:00' }),
    ).rejects.toThrow(HorarioSeCruza);
    expect(repositorio.guardados).toHaveLength(1);
  });

  it('exige que el servicio y la sede sean del negocio', async () => {
    await expect(crear.ejecutar({ ...almuerzo, servicioId: 'cena' })).rejects.toThrow(
      ReferenciaNoEncontrada,
    );
    await expect(crear.ejecutar({ ...almuerzo, sedeId: 'norte' })).rejects.toThrow('sede');
  });

  it('el listado muestra el nombre del servicio', async () => {
    await crear.ejecutar(almuerzo);
    const listado = await new ListarHorarios(repositorio).ejecutar();
    expect(listado).toEqual([{ id: 'id-1', servicioNombre: 'Almuerzo', ...almuerzo }]);
  });
});
