'use client';

import { useMemo } from 'react';
import { useClienteVeci, useComercioActivo } from '@/features/sesion';
import { RepositorioHorariosApi } from './infrastructure/repositorio-horarios-api';
import { HorariosSemana } from './presentation/horarios-semana';

/**
 * Conecta las piezas de la funcionalidad (como un *.module.ts de NestJS): la página
 * solo usa este componente. Módulo de ejemplo de la arquitectura limpia (HU-01-10).
 */
export function PantallaHorarios() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  const repositorio = useMemo(
    () => new RepositorioHorariosApi(cliente, comercioId),
    [cliente, comercioId],
  );
  return <HorariosSemana repositorio={repositorio} />;
}
