'use client';

import { useCallback, useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import { ordenarPizarra, problemaDelTipo } from '../domain/reglas-tiqueteras';
import type { DatosDeTipo, RepositorioPizarra, TipoDeTiquetera } from '../domain/tiquetera';

/** Qué se está escribiendo en la pizarra: nada, un tipo nuevo o uno que ya existe. */
export type Edicion =
  { tipo: 'nada' } | { tipo: 'nuevo' } | { tipo: 'editar'; actual: TipoDeTiquetera };

/** Caso de uso "armar la pizarra" (HU-05-01): crear, cambiar, guardar y volver a vender. */
export function usePizarra(repositorio: RepositorioPizarra) {
  const cargar = useCallback(async () => {
    const [tipos, unidades] = await Promise.all([repositorio.tipos(), repositorio.unidades()]);
    return { tipos: ordenarPizarra(tipos), unidades };
  }, [repositorio]);
  const { estado, recargar } = useCarga(cargar);
  const [edicion, setEdicion] = useState<Edicion>({ tipo: 'nada' });
  const [aviso, setAviso] = useState<string | null>(null);
  const { ocupado, problema, setProblema, ejecutar } = useAccion();

  const listo = async (mensaje: string) => {
    setEdicion({ tipo: 'nada' });
    setAviso(mensaje);
    recargar();
  };

  const guardar = (datos: DatosDeTipo) => {
    const falta = problemaDelTipo(datos);
    if (falta) return setProblema(falta);
    const limpio = { ...datos, nombre: datos.nombre.trim() };
    void ejecutar(async () => {
      if (edicion.tipo === 'editar') {
        await repositorio.editar(edicion.actual.tipoId, limpio);
        await listo(`Listo: «${limpio.nombre}» quedó con los datos nuevos. Lo vendido no cambia.`);
      } else {
        await repositorio.crear(limpio);
        await listo(`Listo: «${limpio.nombre}» ya está en la pizarra y la caja lo puede vender.`);
      }
    });
  };

  const alternar = (tipo: TipoDeTiquetera) =>
    void ejecutar(async () => {
      const activo = tipo.estado !== 'ACTIVE';
      await repositorio.cambiarEstado(tipo.tipoId, activo);
      await listo(
        activo
          ? `«${tipo.nombre}» se vuelve a vender.`
          : `«${tipo.nombre}» se dejó de vender. Las ${tipo.vigentes} que siguen vigentes se consumen normal.`,
      );
    });

  const editar = (siguiente: Edicion) => {
    setProblema(null);
    setAviso(null);
    setEdicion(siguiente);
  };

  return { estado, edicion, editar, guardar, alternar, ocupado, problema, aviso };
}
