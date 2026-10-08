'use client';

import { useMemo } from 'react';
import { useClienteVeci, useComercioActivo } from '@/features/sesion';
import { CuentasApi, PizarraApi } from './infrastructure/repositorio-tiqueteras-api';
import { CuentaDelCliente as Cuenta } from './presentation/cuenta-del-cliente';
import { PantallaPizarra } from './presentation/pantalla-pizarra';
import { PantallaVentas } from './presentation/pantalla-ventas';

function useCuentas() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  return useMemo(() => new CuentasApi(cliente, comercioId), [cliente, comercioId]);
}

/** El id de la venta lo pone el panel: si el cobro se repite, la API no lo duplica. */
const nuevoId = () => crypto.randomUUID();

/** La pizarra de tiqueteras del negocio activo. */
export function Pizarra() {
  const cliente = useClienteVeci();
  const comercioId = useComercioActivo();
  const repositorio = useMemo(() => new PizarraApi(cliente, comercioId), [cliente, comercioId]);
  return <PantallaPizarra repositorio={repositorio} />;
}

/** Las ventas recientes del negocio activo. */
export function Ventas() {
  return <PantallaVentas repositorio={useCuentas()} />;
}

/** Saldo e historia de un cliente, para la ficha de Clientes. */
export function CuentaDelCliente({ clienteId }: { clienteId: string }) {
  return (
    <Cuenta key={clienteId} repositorio={useCuentas()} clienteId={clienteId} nuevoId={nuevoId} />
  );
}
