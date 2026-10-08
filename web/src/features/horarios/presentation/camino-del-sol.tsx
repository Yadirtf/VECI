'use client';

import { Aviso } from '@/shared/ui';
import { diaDeHoy, useCaminoDelSol } from '../application/use-camino-del-sol';
import { DIAS, horaLegible } from '../domain/agrupar-por-dia';
import { aHora } from '../domain/arco';
import type { RepositorioHorarios, SedeCorta } from '../domain/horario';
import { ArcoDelDia, minutosDe, type Segmento } from './arco-del-dia';
import { colorDeServicio } from './colores';
import { DetalleServicio } from './detalle-servicio';
import { NuevoServicio } from './nuevo-servicio';
import { SolesDeLaSemana } from './soles-de-la-semana';

type Camino = ReturnType<typeof useCaminoDelSol>;

function Sedes(p: { sedes: SedeCorta[]; sedeId: string | null; alElegir(id: string): void }) {
  if (p.sedes.length < 2) return null;
  return (
    <div className="flex flex-wrap gap-s" role="radiogroup" aria-label="Sede">
      {p.sedes.map((s) => (
        <button
          key={s.id}
          type="button"
          role="radio"
          aria-checked={s.id === p.sedeId}
          onClick={() => p.alElegir(s.id)}
          className={`min-h-toque-minimo rounded-total px-m text-cuerpo font-medio ${s.id === p.sedeId ? 'bg-selva-oscuro text-superficie' : 'bg-superficie text-selva-oscuro'}`}
        >
          {s.nombre}
        </button>
      ))}
    </div>
  );
}

function segmentos(c: Camino): Segmento[] {
  const servicios = c.datos?.servicios ?? [];
  return c.delDia.map((h) => {
    const elegido = h.id === c.borrador.elegido?.id && c.borrador.rango;
    return {
      horario: h,
      ...(elegido || minutosDe(h)),
      color: colorDeServicio(servicios.findIndex((s) => s.id === h.servicioId)),
    };
  });
}

function centro(c: Camino): { titulo: string; detalle: string } {
  const { elegido, rango } = c.borrador;
  const nombreDia = DIAS.find(([d]) => d === c.dia)?.[1] ?? '';
  if (elegido && rango)
    return {
      titulo: elegido.servicioNombre,
      detalle: `${horaLegible(aHora(rango.inicio))} – ${horaLegible(aHora(rango.fin))}`,
    };
  if (c.delDia.length === 0)
    return { titulo: `${nombreDia} descansas`, detalle: 'Agrega un servicio si abres' };
  return { titulo: nombreDia, detalle: 'Toca un servicio para moverlo' };
}

function Debajo({ c }: { c: Camino }) {
  const { elegido, rango } = c.borrador;
  if (elegido && rango) {
    return (
      <DetalleServicio
        key={elegido.id}
        horario={elegido}
        rango={rango}
        deLaSede={c.deLaSede}
        ocupado={c.accion.ocupado}
        alMover={c.borrador.mover}
        alGuardar={c.guardar}
        alPausar={() => void c.pausar(elegido)}
      />
    );
  }
  if (!c.datos || !c.sedeId) return null;
  const sedeId = c.sedeId;
  return (
    <NuevoServicio
      key={`${sedeId}-${c.dia}`}
      servicios={c.datos.servicios}
      deLaSede={c.deLaSede}
      dia={c.dia}
      ocupado={c.accion.ocupado}
      alCrear={(s, dias, rango) => c.crear(s, sedeId, dias, rango)}
    />
  );
}

function ahoraSiEsHoy(dia: string): number | null {
  const hoy = new Date();
  return dia === diaDeHoy(hoy) ? hoy.getHours() * 60 + hoy.getMinutes() : null;
}

/** Horarios de servicio como el camino del sol de cada día (HU-03-02). */
export function CaminoDelSol({ repositorio }: { repositorio: RepositorioHorarios }) {
  const c = useCaminoDelSol(repositorio);
  if (c.estado.tipo === 'cargando')
    return <Aviso tono="aviso">Un momento, veci, ya traemos tus horarios…</Aviso>;
  if (c.estado.tipo === 'error')
    return (
      <Aviso tono="error">
        No pudimos traer tus horarios. Revisa tu internet y vuelve a intentarlo.
      </Aviso>
    );
  return (
    <div className="flex flex-col gap-l">
      <Sedes
        sedes={c.estado.datos.sedes}
        sedeId={c.sedeId}
        alElegir={(id) => (c.setSede(id), c.borrador.elegir(null))}
      />
      <SolesDeLaSemana horarios={c.deLaSede} dia={c.dia} alElegir={c.elegirDia} />
      <div className="grid gap-l lg:grid-cols-2 lg:items-start">
        <div
          className="flex justify-center overflow-hidden rounded-l bg-superficie px-s pt-m lg:sticky lg:top-m"
          onClick={(e) => e.target === e.currentTarget && c.borrador.elegir(null)}
        >
          <ArcoDelDia
            segmentos={segmentos(c)}
            elegidoId={c.borrador.elegido?.id ?? null}
            ahora={ahoraSiEsHoy(c.dia)}
            alElegir={c.borrador.elegir}
            alMover={c.borrador.mover}
            centro={centro(c)}
          />
        </div>
        <div className="flex min-w-0 flex-col gap-l">
          {c.accion.problema && <Aviso tono="error">{c.accion.problema}</Aviso>}
          <Debajo c={c} />
        </div>
      </div>
      <p className="text-pequeno text-tinta-suave">
        Los cambios llegan al celular de caja la próxima vez que se sincronice.
      </p>
    </div>
  );
}
