'use client';

import { useMemo } from 'react';
import { useClienteVeci } from '@/features/sesion';
import { RepositorioPlataformaApi } from './infrastructure/repositorio-plataforma-api';
import { PantallaSolicitudes } from './presentation/pantalla-solicitudes';

/** Solicitudes de negocio por revisar; el API solo responde al equipo VECI. */
export function SolicitudesDeNegocio() {
  const cliente = useClienteVeci();
  const repositorio = useMemo(() => new RepositorioPlataformaApi(cliente), [cliente]);
  return <PantallaSolicitudes repositorio={repositorio} />;
}
