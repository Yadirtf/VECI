'use client';

import { useMemo } from 'react';
import { useClienteVeci, useComercioActivo } from '@/features/sesion';
import { RepositorioSedesApi } from './infrastructure/repositorio-sedes-api';
import { PantallaSedes } from './presentation/pantalla-sedes';

/** Conecta las piezas de sedes: la página solo usa este componente. */
export function Sedes() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  const repositorio = useMemo(
    () => new RepositorioSedesApi(cliente, comercioId),
    [cliente, comercioId],
  );
  return <PantallaSedes repositorio={repositorio} />;
}
