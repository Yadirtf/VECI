'use client';

import { useMemo } from 'react';
import { useClienteVeci, useComercioActivo } from '@/features/sesion';
import { CuentaDelCliente } from '@/features/tiqueteras';
import { crearClienteVeci } from '@/shared/api/cliente';
import { entorno } from '@/shared/config/entorno';
import { PoliticaApi, RepositorioClientesApi } from './infrastructure/repositorio-clientes-api';
import { PaginaPolitica } from './presentation/pagina-politica';
import { PantallaClientes } from './presentation/pantalla-clientes';

/** Tus clientes, en el panel del negocio activo. */
export function Clientes() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  const repositorio = useMemo(
    () => new RepositorioClientesApi(cliente, comercioId),
    [cliente, comercioId],
  );
  return (
    <PantallaClientes
      repositorio={repositorio}
      cuenta={(clienteId) => <CuentaDelCliente clienteId={clienteId} />}
    />
  );
}

/** Política de datos pública: no pide sesión. */
export function PoliticaDeDatos() {
  const fuente = useMemo(() => new PoliticaApi(crearClienteVeci({ urlBase: entorno.urlApi })), []);
  return <PaginaPolitica fuente={fuente} />;
}
