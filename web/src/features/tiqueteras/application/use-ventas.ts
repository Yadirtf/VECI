'use client';

import { useCallback, useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import { problemaDeCorreccion } from '../domain/reglas-tiqueteras';
import type { Correccion, RepositorioCuentas, VentaReciente } from '../domain/tiquetera';

/** Caso de uso "revisar las ventas y anular la que quedó mal" (HU-05-05). */
export function useVentas(repositorio: RepositorioCuentas) {
  const cargar = useCallback(async () => {
    const [ventas, motivos] = await Promise.all([repositorio.ventas(), repositorio.motivos()]);
    return { ventas, motivos };
  }, [repositorio]);
  const { estado, recargar } = useCarga(cargar);
  const [anulando, setAnulando] = useState<string | null>(null);
  const [aviso, setAviso] = useState<string | null>(null);
  const { ocupado, problema, setProblema, ejecutar } = useAccion();

  const elegir = (ventaId: string | null) => {
    setProblema(null);
    setAviso(null);
    setAnulando(ventaId);
  };

  const anular = (venta: VentaReciente, correccion: Correccion) => {
    const falta = problemaDeCorreccion(correccion);
    if (falta) return setProblema(falta);
    void ejecutar(async () => {
      await repositorio.anular(venta.ventaId, correccion);
      setAnulando(null);
      setAviso(`Anulada la venta de ${venta.cliente}. Queda en la historia con el motivo.`);
      recargar();
    });
  };

  return { estado, anulando, elegir, anular, ocupado, problema, aviso };
}
