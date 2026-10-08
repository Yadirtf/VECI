'use client';

import { setTag } from '@sentry/nextjs';
import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react';
import { crearClienteVeci, type ClienteVeci } from '@/shared/api/cliente';
import { entorno } from '@/shared/config/entorno';
import { AlmacenSesion } from './application/almacen-sesion';
import { useEstadoSesion } from './application/use-sesion';
import { preferenciasNavegador } from './infrastructure/preferencias-navegador';
import { RepositorioSesionBff } from './infrastructure/repositorio-sesion-bff';
import type { MarcoPanelProps } from './presentation/marco-panel';
import { GuardiaPanel, GuardiaSesion, PantallaEntrar } from './presentation/pantallas-sesion';

interface PiezasSesion {
  almacen: AlmacenSesion;
  /** Cliente del API que ya pone el token y renueva solo. */
  cliente: ClienteVeci;
}

const ContextoSesion = createContext<PiezasSesion | null>(null);

function crearPiezas(): PiezasSesion {
  const sinToken = crearClienteVeci({ urlBase: entorno.urlApi });
  const almacen = new AlmacenSesion(new RepositorioSesionBff(sinToken), preferenciasNavegador);
  const cliente = crearClienteVeci({
    urlBase: entorno.urlApi,
    sesion: { tokenVigente: () => almacen.tokenVigente(), renovar: () => almacen.renovar() },
  });
  return { almacen, cliente };
}

/** Va en el layout raíz: una sola sesión para todo el panel. */
export function ProveedorSesion({ children }: { children: ReactNode }) {
  const [piezas] = useState(crearPiezas);
  useEffect(() => {
    void piezas.almacen.iniciar();
    return piezas.almacen.suscribir(() => {
      const estado = piezas.almacen.estado();
      setTag('comercio', estado.fase === 'activa' ? estado.comercioId : null);
    });
  }, [piezas]);
  return <ContextoSesion.Provider value={piezas}>{children}</ContextoSesion.Provider>;
}

function usePiezas(): PiezasSesion {
  const piezas = useContext(ContextoSesion);
  if (!piezas) throw new Error('Falta <ProveedorSesion> en el layout raíz');
  return piezas;
}

export const useClienteVeci = (): ClienteVeci => usePiezas().cliente;

/** Negocio con el que se trabaja; solo se usa dentro del panel, que exige haberlo elegido. */
export function useComercioActivo(): string {
  const estado = useEstadoSesion(usePiezas().almacen);
  if (estado.fase !== 'activa' || !estado.comercioId) throw new Error('Sin negocio activo');
  return estado.comercioId;
}

/** Permisos de la consola VECI de quien entró (vacío si no es del equipo VECI). */
export function usePermisosDePlataforma(): () => Promise<string[]> {
  const { almacen } = usePiezas();
  return useCallback(() => almacen.permisosDePlataforma(), [almacen]);
}

/** Exige sesión abierta (con o sin negocio elegido); sin sesión manda a /entrar. */
export function ConSesion({ children }: { children: (nombre: string) => ReactNode }) {
  return <GuardiaSesion almacen={usePiezas().almacen}>{children}</GuardiaSesion>;
}

export function Entrar() {
  return <PantallaEntrar almacen={usePiezas().almacen} />;
}

export function Panel({ menu, children }: { menu: MarcoPanelProps['menu']; children: ReactNode }) {
  return (
    <GuardiaPanel almacen={usePiezas().almacen} menu={menu}>
      {children}
    </GuardiaPanel>
  );
}
