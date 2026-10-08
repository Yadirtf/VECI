'use client';

import { useCallback, useMemo } from 'react';
import { useClienteVeci, useComercioActivo } from '@/features/sesion';
import { useAlta } from './application/use-alta';
import { borradorNavegador } from './infrastructure/borrador-navegador';
import { RepositorioComerciosApi } from './infrastructure/repositorio-comercios-api';
import { CaminoDeApertura } from './presentation/camino-de-apertura';
import { MiNegocio } from './presentation/mi-negocio';
import { SolicitudDeNegocio } from './presentation/solicitud-de-negocio';

/** Pedir el registro de un negocio (no exige tener uno elegido). */
export function RegistrarNegocio() {
  const cliente = useClienteVeci();
  const repositorio = useMemo(() => new RepositorioComerciosApi(cliente), [cliente]);
  const alta = useAlta(repositorio, borradorNavegador);
  const cargarCatalogos = useCallback(
    async () => ({ tipos: await repositorio.tipos(), municipios: await repositorio.municipios() }),
    [repositorio],
  );
  const misSolicitudes = useCallback(() => repositorio.misSolicitudes(), [repositorio]);
  return (
    <SolicitudDeNegocio
      alta={alta}
      cargarCatalogos={cargarCatalogos}
      misSolicitudes={misSolicitudes}
    />
  );
}

function useRepositorioDelNegocio() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  return useMemo(() => new RepositorioComerciosApi(cliente, comercioId), [cliente, comercioId]);
}

/** Inicio del panel: qué falta para abrir el negocio. */
export function InicioNegocio() {
  return <CaminoDeApertura repositorio={useRepositorioDelNegocio()} />;
}

/** Datos del negocio que la dueña puede cambiar. */
export function DatosDelNegocio() {
  return <MiNegocio repositorio={useRepositorioDelNegocio()} />;
}
