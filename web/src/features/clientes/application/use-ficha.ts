'use client';

import { useCallback } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import type { FichaCliente, RepositorioClientes } from '../domain/cliente';
import type { PinVisible } from './use-libreta';

/** Caso de uso "ver la ficha de un cliente" y darle su PIN de bienvenida si lo espera. */
export function useFicha(
  repositorio: RepositorioClientes,
  clienteId: string,
  alDarPin: (pin: PinVisible) => void,
) {
  const cargar = useCallback(() => repositorio.ficha(clienteId), [repositorio, clienteId]);
  const { estado } = useCarga(cargar);
  const { ocupado, problema, ejecutar } = useAccion();

  const darPin = (ficha: FichaCliente) =>
    void ejecutar(async () => {
      const pin = await repositorio.darPinBienvenida(ficha.clienteId);
      alDarPin({ nombre: ficha.nombres, pin });
    });

  return { estado, ocupado, problema, darPin };
}
