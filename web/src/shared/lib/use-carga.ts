'use client';

import { useCallback, useEffect, useState } from 'react';

export type EstadoCarga<T> =
  { tipo: 'cargando' } | { tipo: 'listo'; datos: T } | { tipo: 'error'; mensaje: string };

/** Trae datos al montar y cuando se pide recargar; ignora respuestas que llegan tarde. */
export function useCarga<T>(cargar: () => Promise<T>) {
  const [estado, setEstado] = useState<EstadoCarga<T>>({ tipo: 'cargando' });
  const [vuelta, setVuelta] = useState(0);

  useEffect(() => {
    let vigente = true;
    cargar()
      .then((datos) => vigente && setEstado({ tipo: 'listo', datos }))
      .catch((e: unknown) => {
        const mensaje = e instanceof Error ? e.message : 'No pudimos traer la información.';
        if (vigente) setEstado({ tipo: 'error', mensaje });
      });
    return () => {
      vigente = false;
    };
  }, [cargar, vuelta]);

  const recargar = useCallback(() => setVuelta((v) => v + 1), []);
  return { estado, recargar };
}
