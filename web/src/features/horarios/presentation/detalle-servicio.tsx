'use client';

import { useState } from 'react';
import { Boton } from '@/shared/ui';
import type { Extremo } from '../domain/dia-de-servicio';
import type { Horario } from '../domain/horario';
import type { Rango } from '../domain/programacion';
import { HorasDelServicio } from './ajuste-hora';
import { GuardarEnDias } from './guardar-en-dias';

interface Props {
  horario: Horario;
  rango: Rango;
  deLaSede: readonly Horario[];
  ocupado: boolean;
  alMover(extremo: Extremo, minutos: number): void;
  alGuardar(dias: string[]): Promise<boolean>;
  alPausar(): void;
}

/**
 * Lo que se hace con el servicio elegido: afinar las horas y guardarlas en ese día o
 * en varios a la vez (lunes a viernes, por ejemplo), o ponerlo en pausa.
 */
export function DetalleServicio(p: Props) {
  const [dias, setDias] = useState<string[]>([p.horario.dia]);
  return (
    <section aria-label={`Servicio ${p.horario.servicioNombre}`} className="flex flex-col gap-l">
      <HorasDelServicio rango={p.rango} alMover={p.alMover} />
      <div className="rounded-l bg-crema p-m">
        <GuardarEnDias
          deLaSede={p.deLaSede}
          servicioId={p.horario.servicioId}
          rango={p.rango}
          dias={dias}
          alCambiarDias={setDias}
          ocupado={p.ocupado}
          alGuardar={(elegidos) => void p.alGuardar(elegidos)}
        />
      </div>
      <Boton variante="secundario" disabled={p.ocupado} className="self-start" onClick={p.alPausar}>
        {p.horario.activo ? 'Pausar este servicio' : 'Reanudar este servicio'}
      </Boton>
    </section>
  );
}
