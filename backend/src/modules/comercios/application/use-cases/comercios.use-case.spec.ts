import { EntradaAuditoria } from '../../../../shared/application/puertos/auditoria.port';
import { InvitarCajero } from '../../../personal';
import { ComerciosEnMemoria } from './comercios-en-memoria.fake';
import { PerfilDelComercio } from './perfil-comercio.use-case';
import { RegistrarComercio } from './registrar-comercio.use-case';
import { RegistrarComercioParaPropietario } from './registrar-para-propietario.use-case';

describe('Comercios (HU-03-01)', () => {
  let comercios: ComerciosEnMemoria;
  let auditoria: EntradaAuditoria[];
  let registrar: RegistrarComercio;
  const entrada = {
    nombre: 'Restaurante La Vecina',
    tipoNegocio: 'RESTAURANT',
    tipoDocumento: 'NIT',
    numeroDocumento: '800197268',
    celular: '310 000 0101',
  };

  beforeEach(() => {
    comercios = new ComerciosEnMemoria();
    auditoria = [];
    registrar = new RegistrarComercio({
      comercios,
      ids: { siguiente: () => 'nuevo' },
      auditoria: { registrar: async (e) => void auditoria.push(e) },
    });
  });

  it('el dueño registra su negocio y queda como propietario', async () => {
    await expect(registrar.ejecutar('marta', entrada)).resolves.toEqual({
      comercioId: 'nuevo',
      slug: 'restaurante-la-vecina',
    });
    const [alta] = comercios.altas;
    expect(alta.propietarioId).toBe('marta');
    expect(alta.documento.numero).toBe('8001972684');
    expect(alta.celular).toBe('+573100000101');
    expect(auditoria[0]).toEqual(
      expect.objectContaining({ accion: 'TENANT_CREATED', comercioId: 'nuevo' }),
    );
  });

  it('el tipo de negocio debe estar en el catálogo', async () => {
    await expect(registrar.ejecutar('marta', { ...entrada, tipoNegocio: 'SPA' })).rejects.toThrow(
      'tipo de negocio',
    );
    expect(comercios.altas).toHaveLength(0);
  });

  it('VECI registra el negocio e invita al dueño como propietario', async () => {
    const llamadas: unknown[] = [];
    const fijados: unknown[] = [];
    const invitar = {
      propietario: async (actor: unknown, persona: unknown) => {
        llamadas.push([actor, persona]);
        return { membresiaId: 'm-1', pinTemporal: '730284' };
      },
    } as unknown as InvitarCajero;
    const caso = new RegistrarComercioParaPropietario({
      registrar,
      invitar,
      almacen: {
        ejecutar: (fn) => fn(),
        fijarComercio: (c) => void fijados.push(c),
        comercioActual: () => null,
      },
    });
    const persona = {
      celular: '3124567890',
      nombres: 'Rosa',
      apellidos: null,
      tipoDocumento: 'CC',
      numeroDocumento: '1124500777',
    };
    const resultado = await caso.ejecutar('admin', entrada, persona);
    expect(resultado.pinTemporal).toBe('730284');
    expect(comercios.altas[0].propietarioId).toBeNull();
    expect(fijados).toEqual([{ usuarioId: 'admin', comercioId: 'nuevo' }]);
    expect(llamadas).toHaveLength(1);
  });
});

describe('Perfil y apertura del negocio', () => {
  let comercios: ComerciosEnMemoria;
  let perfil: PerfilDelComercio;

  beforeEach(() => {
    comercios = new ComerciosEnMemoria();
    perfil = new PerfilDelComercio(comercios);
  });

  it('muestra el camino: sin horarios no puede abrir', async () => {
    const actual = await perfil.consultar();
    expect(actual.puedeAbrir).toBe(false);
    expect(actual.camino.find((p) => p.codigo === 'HORARIOS')).toEqual({
      codigo: 'HORARIOS',
      listo: false,
      obligatorio: true,
    });
    await expect(perfil.abrir()).rejects.toThrow('al menos un horario');
  });

  it('con un horario abre sus puertas una sola vez', async () => {
    comercios.perfilActual = {
      ...comercios.perfilActual,
      avance: { serviciosConHorario: 1, cajeros: 0, tiqueteras: 0 },
    };
    expect((await perfil.consultar()).puedeAbrir).toBe(true);
    expect((await perfil.abrir()).abierto).toBe(true);
    await expect(perfil.abrir()).rejects.toThrow('ya está abierto');
    expect(comercios.abiertos).toBe(1);
  });

  it('edita solo lo que llega y valida cada dato', async () => {
    await perfil.editar({ nombre: ' La Vecina  2 ', correo: null });
    expect(comercios.cambios[0]).toEqual(
      expect.objectContaining({ correo: null, celular: undefined, logoUrl: undefined }),
    );
    expect(comercios.cambios[0].nombre?.valor).toBe('La Vecina 2');
    await expect(perfil.editar({ celular: '12' })).rejects.toThrow('celular');
    await expect(perfil.editar({ tipoNegocio: 'SPA' })).rejects.toThrow('tipo de negocio');
  });
});
