'use client';

import { useState } from 'react';
import { Boton } from '@/shared/ui';
import { horaLegible } from '../domain/agrupar-por-dia';
import { aHora, PASO_MINUTOS } from '../domain/arco';
import type { Extremo } from '../domain/dia-de-servicio';
import type { Horario } from '../domain/horario';
import { DiasElegibles } from './dias-elegibles';

function Ajuste(p: { etiqueta: string; minutos: number; alCambiar(minutos: number): void }) {
  const boton =
    'h-toque-boton w-toque-boton rounded-total border-2 border-selva text-titulo font-fuerte text-selva-oscuro hover:bg-selva-claro';
  return (
    <div className="flex items-center gap-s">
      <button
        type="button"
        className={boton}
        aria-label={`${p.etiqueta} 15 minutos antes`}
        onClick={() => p.alCambiar(p.minutos - PASO_MINUTOS)}
      >
        −
      </button>
      <p className="min-w-32 text-center">
        <span className="block text-pequeno text-tinta-suave">{p.etiqueta}</span>
        <span className="text-titulo font-fuerte">{horaLegible(aHora(p.minutos))}</span>
      </p>
      <button
        type="button"
        className={boton}
        aria-label={`${p.etiqueta} 15 minutos después`}
        onClick={() => p.alCambiar(p.minutos + PASO_MINUTOS)}
      >
        +
      </button>
    </div>
  );
}

interface Props {
  horario: Horario;
  rango: { inicio: number; fin: number };
  cambiado: boolean;
  ocupado: boolean;
  alMover(extremo: Extremo, minutos: number): void;
  alGuardar(): void;
  alPausar(): void;
  alCopiar(dias: string[]): Promise<boolean>;
}

function IgualEn({ horario, ocupado, alCopiar }: Pick<Props, 'horario' | 'ocupado' | 'alCopiar'>) {
  const [dias, setDias] = useState<string[]>([]);
  return (
    <details className="rounded-l bg-crema p-m">
      <summary className="cursor-pointer text-subtitulo font-medio text-selva-oscuro">
        Igual en otros días…
      </summary>
      <div className="mt-m flex flex-col gap-m">
        <DiasElegibles elegidos={dias} sin={horario.dia} alCambiar={setDias} />
        <Boton
          variante="secundario"
          disabled={ocupado || dias.length === 0}
          className="self-start"
          onClick={() => void alCopiar(dias).then((ok) => ok && setDias([]))}
        >
          Copiar {horario.servicioNombre.toLowerCase()} a {dias.length || 'esos'}{' '}
          {dias.length === 1 ? 'día' : 'días'}
        </Boton>
      </div>
    </details>
  );
}

/** Lo que se hace con el servicio elegido: afinar con botones, guardar, pausar o copiar. */
export function DetalleServicio(p: Props) {
  return (
    <section aria-label={`Servicio ${p.horario.servicioNombre}`} className="flex flex-col gap-l">
      <div className="flex flex-wrap items-center gap-l">
        <Ajuste
          etiqueta="Empieza"
          minutos={p.rango.inicio}
          alCambiar={(m) => p.alMover('inicio', m)}
        />
        <Ajuste etiqueta="Termina" minutos={p.rango.fin} alCambiar={(m) => p.alMover('fin', m)} />
      </div>
      <div className="flex flex-wrap gap-m">
        {p.cambiado && (
          <Boton disabled={p.ocupado} onClick={p.alGuardar}>
            Guardar nuevas horas
          </Boton>
        )}
        <Boton variante="secundario" disabled={p.ocupado} onClick={p.alPausar}>
          {p.horario.activo ? 'Pausar este servicio' : 'Reanudar este servicio'}
        </Boton>
      </div>
      <IgualEn horario={p.horario} ocupado={p.ocupado} alCopiar={p.alCopiar} />
    </section>
  );
}
