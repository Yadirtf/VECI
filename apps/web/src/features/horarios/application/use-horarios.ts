'use client';

import { useEffect, useState } from 'react';
import { agruparPorDia, type DiaConHorarios } from '../domain/agrupar-por-dia';
import type { RepositorioHorarios } from '../domain/horario';

export type EstadoHorarios =
  { tipo: 'cargando' } | { tipo: 'listo'; dias: DiaConHorarios[] } | { tipo: 'error' };

/** Caso de uso "ver los horarios de la semana" para la pantalla del panel. */
export function useHorarios(repositorio: RepositorioHorarios): EstadoHorarios {
  const [estado, setEstado] = useState<EstadoHorarios>({ tipo: 'cargando' });

  useEffect(() => {
    let vigente = true;
    repositorio
      .listar()
      .then((horarios) => vigente && setEstado({ tipo: 'listo', dias: agruparPorDia(horarios) }))
      .catch(() => vigente && setEstado({ tipo: 'error' }));
    return () => {
      vigente = false;
    };
  }, [repositorio]);

  return estado;
}
