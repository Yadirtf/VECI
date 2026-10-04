'use client';

import { useMemo } from 'react';
import { useClienteVeci, useComercioActivo } from '@/features/sesion';
import { RepositorioEquipoApi } from './infrastructure/repositorio-equipo-api';
import { PantallaDispositivos } from './presentation/pantalla-dispositivos';
import { PantallaEquipo } from './presentation/pantalla-equipo';

function useRepositorio() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  return useMemo(() => new RepositorioEquipoApi(cliente, comercioId), [cliente, comercioId]);
}

export function Equipo() {
  return <PantallaEquipo repositorio={useRepositorio()} />;
}

export function Dispositivos() {
  return <PantallaDispositivos repositorio={useRepositorio()} />;
}
