'use client';

import { useSyncExternalStore } from 'react';
import type { AlmacenSesion, EstadoSesion } from './almacen-sesion';

const INICIANDO: EstadoSesion = { fase: 'iniciando' };

/** Estado de la sesión para los componentes; se vuelve a pintar con cada cambio. */
export function useEstadoSesion(almacen: AlmacenSesion): EstadoSesion {
  return useSyncExternalStore(almacen.suscribir, almacen.estado, () => INICIANDO);
}
