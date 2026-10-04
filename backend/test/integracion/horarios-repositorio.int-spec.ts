import { Client } from 'pg';
import { GeneradorUuidV7 } from '../../src/shared/infrastructure/ids/uuid-v7.generador';
import { PrismaService } from '../../src/shared/infrastructure/prisma/prisma.service';
import { TransaccionComercio } from '../../src/shared/infrastructure/prisma/transaccion-comercio';
import { CodigoCatalogo } from '../../src/shared/domain/codigo-catalogo.vo';
import { HorarioServicio } from '../../src/modules/horarios/domain/entities/horario-servicio.entity';
import { HorarioSeCruza } from '../../src/modules/horarios/domain/errors/horario-se-cruza.error';
import { RangoHoras } from '../../src/modules/horarios/domain/value-objects/rango-horas.vo';
import { PrismaHorarioServicioRepository } from '../../src/modules/horarios/infrastructure/persistence/prisma-horario-servicio.repository';
import { ComercioDePrueba, conectarDueno } from '../soporte/base-de-datos';
import { crearComercio } from '../soporte/escenario';
import { crearTransacciones } from '../soporte/transacciones';

// La restricción de exclusión de PostgreSQL es la última red contra horarios que se cruzan,
// aunque dos cajeros los creen al mismo tiempo y ambos pasen la regla del dominio.
describe('PrismaHorarioServicioRepository', () => {
  let dueno: Client;
  let prisma: PrismaService;
  let transaccion: TransaccionComercio;
  let comercio: ComercioDePrueba;
  const ids = new GeneradorUuidV7();

  const horario = (inicio: string, fin: string) =>
    HorarioServicio.crear({
      id: ids.siguiente(),
      servicioId: comercio.servicioId,
      sedeId: comercio.sedeId,
      dia: CodigoCatalogo.de('FRIDAY'),
      horas: RangoHoras.de(inicio, fin),
    });

  const conComercio = <T>(trabajo: (repo: PrismaHorarioServicioRepository) => Promise<T>) => {
    const almacenado = { comercioId: comercio.comercioId, usuarioId: comercio.usuarioId };
    const repositorio = new PrismaHorarioServicioRepository({
      ejecutar: (fn) => transaccion.ejecutarComo(almacenado, fn),
    } as TransaccionComercio);
    return trabajo(repositorio);
  };

  beforeAll(async () => {
    dueno = await conectarDueno();
    ({ prisma, transaccion } = crearTransacciones());
    comercio = await crearComercio(dueno);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await dueno.end();
  });

  it('guarda y lee el horario con sus horas', async () => {
    await conComercio((repo) => repo.guardar(horario('18:00', '21:00')));
    const guardados = await conComercio((repo) =>
      repo.listarDeSedeYDia(comercio.sedeId, CodigoCatalogo.de('FRIDAY')),
    );
    expect(guardados.map((h) => [h.horas.inicio, h.horas.fin])).toEqual([['18:00', '21:00']]);
  });

  it('traduce la restricción de exclusión a HorarioSeCruza', async () => {
    await expect(conComercio((repo) => repo.guardar(horario('20:00', '22:00')))).rejects.toThrow(
      HorarioSeCruza,
    );
  });

  it('un día que no existe en el catálogo es un dato inválido', async () => {
    const enDomingo = HorarioServicio.crear({
      id: ids.siguiente(),
      servicioId: comercio.servicioId,
      sedeId: comercio.sedeId,
      dia: CodigoCatalogo.de('FUNDAY'),
      horas: RangoHoras.de('06:00', '07:00'),
    });
    await expect(conComercio((repo) => repo.guardar(enDomingo))).rejects.toThrow('no es un día');
  });
});
