'use client';

import { Aviso, Tarjeta } from '@/shared/ui';
import { useHorarios } from '../application/use-horarios';
import { horaLegible } from '../domain/agrupar-por-dia';
import type { RepositorioHorarios } from '../domain/horario';

/** Horarios de servicio de la semana, agrupados por día. */
export function HorariosSemana({ repositorio }: { repositorio: RepositorioHorarios }) {
  const estado = useHorarios(repositorio);

  if (estado.tipo === 'cargando')
    return <Aviso tono="aviso">Un momento, veci, ya traemos tus horarios…</Aviso>;
  if (estado.tipo === 'error') {
    return (
      <Aviso tono="error">
        No pudimos traer tus horarios. Revisa tu internet y vuelve a intentarlo.
      </Aviso>
    );
  }
  if (estado.dias.length === 0) {
    return (
      <Aviso tono="aviso">
        Aún no tienes horarios de servicio. Crea el primero y empieza a vender.
      </Aviso>
    );
  }
  return (
    <div className="grid gap-m sm:grid-cols-2 lg:grid-cols-3">
      {estado.dias.map((grupo) => (
        <Tarjeta key={grupo.dia} aria-label={grupo.nombre}>
          <h2 className="mb-s text-titulo font-fuerte text-tinta">{grupo.nombre}</h2>
          <ul className="flex flex-col gap-s">
            {grupo.horarios.map((h) => (
              <li key={h.id} className="flex justify-between gap-m text-cuerpo">
                <span className="font-medio">{h.servicioNombre}</span>
                <span className="text-tinta-suave">
                  {horaLegible(h.horaInicio)} – {horaLegible(h.horaFin)}
                </span>
              </li>
            ))}
          </ul>
        </Tarjeta>
      ))}
    </div>
  );
}
