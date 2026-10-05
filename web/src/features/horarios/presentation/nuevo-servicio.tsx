'use client';

import { useState } from 'react';
import { Boton, Campo } from '@/shared/ui';
import { horaLegible } from '../domain/agrupar-por-dia';
import { aHora } from '../domain/arco';
import type { Servicio } from '../domain/horario';
import { DiasElegibles } from './dias-elegibles';

interface Props {
  servicios: Servicio[];
  dia: string;
  hueco: { inicio: number; fin: number } | null;
  ocupado: boolean;
  alCrear(servicio: Servicio | string, dias: string[]): Promise<boolean>;
}

function ElegirServicio(p: { servicios: Servicio[]; elegido: string; alElegir(id: string): void }) {
  const opciones = [
    ...p.servicios.map((s) => ({ id: s.id, nombre: s.nombre })),
    { id: 'OTRO', nombre: 'Otro…' },
  ];
  return (
    <div className="flex flex-wrap gap-s">
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

/** Agregar un servicio en el primer hueco del día; luego se estira en el arco. */
export function NuevoServicio(p: Props) {
  const [servicioId, setServicioId] = useState(p.servicios[0]?.id ?? 'OTRO');
  const [nombre, setNombre] = useState('');
  const [dias, setDias] = useState<string[]>([p.dia]);
  if (!p.hueco)
    return (
      <p className="text-cuerpo text-tinta-suave">
        Este día ya no tiene espacio libre entre las 6 a. m. y las 10 p. m.
      </p>
    );
  const servicio =
    servicioId === 'OTRO' ? nombre.trim() : p.servicios.find((s) => s.id === servicioId);
  const listo = !!servicio && dias.length > 0;
  return (
    <details className="rounded-l border-2 border-dashed border-borde p-m">
      <summary className="cursor-pointer text-subtitulo font-medio text-arcilla">
        Agregar un servicio
      </summary>
      <div className="mt-m flex flex-col gap-m">
        <ElegirServicio servicios={p.servicios} elegido={servicioId} alElegir={setServicioId} />
        {servicioId === 'OTRO' && (
          <Campo
            etiqueta="¿Cómo se llama?"
            value={nombre}
            maxLength={40}
            placeholder="Onces"
            onChange={(e) => setNombre(e.target.value)}
          />
        )}
        <DiasElegibles elegidos={dias} alCambiar={setDias} />
        <p className="text-cuerpo text-tinta-suave">
          Lo ponemos de {horaLegible(aHora(p.hueco.inicio))} a {horaLegible(aHora(p.hueco.fin))};
          después lo estiras en el arco.
        </p>
        <Boton
          disabled={!listo || p.ocupado}
          className="self-start"
          onClick={() =>
            servicio && void p.alCrear(servicio, dias).then((ok) => ok && setNombre(''))
          }
        >
          Agregar
        </Boton>
      </div>
    </details>
  );
}
