'use client';

import { useState } from 'react';
import { Campo } from '@/shared/ui';
import { FIN_DEL_DIA, moverExtremo, type Extremo } from '../domain/dia-de-servicio';
import type { Horario, Servicio } from '../domain/horario';
import { horasSugeridas, type Rango } from '../domain/programacion';
import { HorasDelServicio } from './ajuste-hora';
import { GuardarEnDias } from './guardar-en-dias';

const OTRO = 'OTRO';

interface Props {
  servicios: Servicio[];
  deLaSede: readonly Horario[];
  dia: string;
  ocupado: boolean;
  alCrear(servicio: Servicio | string, dias: string[], rango: Rango): Promise<boolean>;
}

function ElegirServicio(p: { servicios: Servicio[]; elegido: string; alElegir(id: string): void }) {
  const opciones = [...p.servicios, { id: OTRO, nombre: 'Otro…' }];
  return (
    <div className="flex flex-wrap gap-s" role="group" aria-label="Servicio">
      {opciones.map((s) => (
        <button
          key={s.id}
          type="button"
          aria-pressed={p.elegido === s.id}
          onClick={() => p.alElegir(s.id)}
          className={`min-h-toque-minimo rounded-total border-2 px-m text-cuerpo font-medio ${p.elegido === s.id ? 'border-arcilla bg-arcilla text-superficie' : 'border-borde bg-superficie text-arcilla hover:border-arcilla'}`}
        >
          {s.nombre}
        </button>
      ))}
    </div>
  );
}

function useFormulario(p: Props) {
  const [servicioId, setServicioId] = useState(p.servicios[0]?.id ?? OTRO);
  const [nombre, setNombre] = useState('');
  const [dias, setDias] = useState<string[]>([p.dia]);
  const sugerir = (id: string, texto: string) =>
    horasSugeridas(p.deLaSede, p.dia, {
      id: id === OTRO ? null : id,
      nombre: id === OTRO ? texto : (p.servicios.find((s) => s.id === id)?.nombre ?? ''),
    });
  const [rango, setRango] = useState<Rango>(() => sugerir(servicioId, ''));
  const elegirServicio = (id: string) => (setServicioId(id), setRango(sugerir(id, nombre)));
  const mover = (extremo: Extremo, minutos: number) =>
    setRango((r) => moverExtremo(r, extremo, minutos, { minInicio: 0, maxFin: FIN_DEL_DIA }));
  const servicio =
    servicioId === OTRO ? nombre.trim() : p.servicios.find((s) => s.id === servicioId);
  return { servicioId, nombre, setNombre, dias, setDias, rango, elegirServicio, mover, servicio };
}

/**
 * Programar un servicio nuevo en la semana: cuál, a qué horas y qué días, todo de
 * una vez (HU-03-02). Propone las horas de costumbre y avisa si algo se cruza.
 */
export function NuevoServicio(p: Props) {
  const f = useFormulario(p);
  return (
    <details className="rounded-l border-2 border-dashed border-borde p-m">
      <summary className="cursor-pointer text-subtitulo font-medio text-arcilla">
        Agregar un servicio
      </summary>
      <div className="mt-m flex flex-col gap-l">
        <ElegirServicio
          servicios={p.servicios}
          elegido={f.servicioId}
          alElegir={f.elegirServicio}
        />
        {f.servicioId === OTRO && (
          <Campo
            etiqueta="¿Cómo se llama?"
            value={f.nombre}
            maxLength={40}
            placeholder="Onces"
            onChange={(e) => f.setNombre(e.target.value)}
          />
        )}
        <HorasDelServicio rango={f.rango} alMover={f.mover} />
        <GuardarEnDias
          deLaSede={p.deLaSede}
          servicioId={f.servicioId === OTRO ? null : f.servicioId}
          rango={f.rango}
          dias={f.dias}
          alCambiarDias={f.setDias}
          ocupado={p.ocupado}
          listo={!!f.servicio}
          alGuardar={(dias) =>
            f.servicio &&
            void p.alCrear(f.servicio, dias, f.rango).then((ok) => ok && f.setNombre(''))
          }
        />
      </div>
    </details>
  );
}
