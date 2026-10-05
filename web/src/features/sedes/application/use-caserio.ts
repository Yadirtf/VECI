'use client';

import { useCallback } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import { alternarSede } from '../domain/reglas-sedes';
import type { CajeroEnSedes, RepositorioSedes, Sede } from '../domain/sede';

/** Caso de uso "organizar las sedes y quién trabaja en cada una" (HU-03-03). */
export function useCaserio(repositorio: RepositorioSedes) {
  const cargar = useCallback(() => repositorio.mapa(), [repositorio]);
  const { estado, recargar } = useCarga(cargar);
  const accion = useAccion();
  const hecho = (f: () => Promise<void>) => accion.ejecutar(async () => (await f(), recargar()));
  const sedes = estado.tipo === 'listo' ? estado.datos.sedes : [];
  return {
    estado,
    accion,
    crear: (nombre: string, direccion: string | null) =>
      hecho(() => repositorio.crear(nombre, direccion)),
    cambiarActiva: (sede: Sede) => hecho(() => repositorio.cambiarActiva(sede.id, !sede.activa)),
    alternar: (cajero: CajeroEnSedes, sedeId: string) =>
      hecho(() => repositorio.asignar(cajero.membresiaId, alternarSede(cajero, sedeId, sedes))),
  };
}
