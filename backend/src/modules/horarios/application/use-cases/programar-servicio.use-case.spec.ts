import { HorarioSeCruza } from '../../domain/errors/horario-se-cruza.error';
import { CambiarHorario } from './cambiar-horario.use-case';
import { CrearHorario } from './crear-horario.use-case';
import { HorariosEnMemoria } from './horarios-en-memoria.fake';
import { ProgramarServicio } from './programar-servicio.use-case';

describe('Programar un servicio en varios días', () => {
  let repositorio: HorariosEnMemoria;
  let crear: CrearHorario;
  let programar: ProgramarServicio;
  let contador: number;
  const ids = { siguiente: () => `id-${++contador}` };
  const semana = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];
  const almuerzo = {
    servicioId: 'almuerzo',
    sedeId: 'principal',
    dias: semana,
    horaInicio: '11:30',
    horaFin: '15:00',
  };
  const horasPorDia = () =>
    repositorio.guardados.map((h) => `${h.servicioId} ${h.dia.valor} ${h.horas.inicio}`);

  beforeEach(() => {
    contador = 0;
    repositorio = new HorariosEnMemoria(
      { desayuno: 'Desayuno', almuerzo: 'Almuerzo', cena: 'Cena' },
      ['principal', 'norte'],
    );
    crear = new CrearHorario(repositorio, ids);
    programar = new ProgramarServicio(repositorio, ids);
  });

  it('crea el servicio en todos los días elegidos', async () => {
    const programados = await programar.ejecutar(almuerzo);
    expect(programados.map((h) => h.dia)).toEqual(semana);
    expect(repositorio.guardados).toHaveLength(5);
  });

  it('cambia las horas donde el servicio ya estaba, sin chocar con su horario viejo', async () => {
    await crear.ejecutar({
      ...almuerzo,
      dias: ['MONDAY', 'TUESDAY'],
      horaInicio: '08:00',
      horaFin: '10:00',
    });
    await programar.ejecutar(almuerzo);
    expect(repositorio.cerrados).toEqual(['id-1', 'id-2']);
    expect(horasPorDia()).toEqual(semana.map((d) => `almuerzo ${d} 11:30`));
  });

  it('reemplaza también el que estaba en pausa y lo deja activo', async () => {
    await crear.ejecutar({ ...almuerzo, dias: ['MONDAY'] });
    await new CambiarHorario(repositorio, ids).cambiarEstado('id-1', false);
    const [lunes] = await programar.ejecutar({ ...almuerzo, dias: ['MONDAY'] });
    expect(lunes.activo).toBe(true);
    expect(repositorio.guardados).toHaveLength(1);
  });

  it('desayuno, almuerzo y cena quedan juntos sin cruzarse', async () => {
    await programar.ejecutar({
      ...almuerzo,
      servicioId: 'desayuno',
      horaInicio: '06:00',
      horaFin: '09:00',
    });
    await programar.ejecutar(almuerzo);
    await programar.ejecutar({
      ...almuerzo,
      servicioId: 'cena',
      horaInicio: '18:00',
      horaFin: '21:00',
    });
    expect(repositorio.guardados).toHaveLength(15);
  });

  it('no toca los días que ya tienen esas horas', async () => {
    await programar.ejecutar({ ...almuerzo, dias: ['MONDAY'] });
    const antes = await repositorio.version();
    const [lunes] = await programar.ejecutar({ ...almuerzo, dias: ['MONDAY'] });
    expect(lunes.id).toBe('id-1');
    expect(await repositorio.version()).toBe(antes);
  });

  it('si otro servicio se cruza un día, dice cuál y no cambia ninguno', async () => {
    await crear.ejecutar({
      ...almuerzo,
      servicioId: 'desayuno',
      dias: ['WEDNESDAY'],
      horaInicio: '07:00',
      horaFin: '12:00',
    });
    const intento = programar.ejecutar(almuerzo);
    await expect(intento).rejects.toThrow(HorarioSeCruza);
    await expect(intento).rejects.toThrow('El miércoles se cruza con Desayuno (07:00 a 12:00)');
    expect(repositorio.guardados).toHaveLength(1);
  });

  it('solo mira la sede elegida', async () => {
    await crear.ejecutar({ ...almuerzo, servicioId: 'cena', sedeId: 'norte' });
    await expect(programar.ejecutar(almuerzo)).resolves.toHaveLength(5);
  });

  it('pide al menos un día y que el servicio sea del negocio', async () => {
    await expect(programar.ejecutar({ ...almuerzo, dias: [] })).rejects.toThrow('al menos un día');
    await expect(programar.ejecutar({ ...almuerzo, servicioId: 'onces' })).rejects.toThrow(
      'servicio',
    );
  });
});
