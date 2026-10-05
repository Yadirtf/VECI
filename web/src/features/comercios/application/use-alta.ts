'use client';

import { useCallback, useState } from 'react';
import {
  aDatosAlta,
  BORRADOR_VACIO,
  PASOS,
  problemaEnPaso,
  type BorradorAlta,
} from '../domain/alta';
import type { RepositorioComercios } from '../domain/comercio';

/** Dónde se guarda lo escrito mientras tanto (el navegador); puede fallar sin romper nada. */
export interface AlmacenBorrador {
  leer(): BorradorAlta | null;
  guardar(borrador: BorradorAlta | null): void;
}

/**
 * La conversación del alta: una pregunta a la vez, lo escrito queda guardado y al
 * final se registra el negocio. Devuelve el id para dejarlo activo.
 */
export function useAlta(repositorio: RepositorioComercios, almacen: AlmacenBorrador) {
  const [indice, setIndice] = useState(0);
  // Se monta solo en el navegador (tras la guardia de sesión): leer aquí no descuadra el SSR.
  const [borrador, setBorrador] = useState<BorradorAlta>(() => almacen.leer() ?? BORRADOR_VACIO);
  const [problema, setProblema] = useState<string | null>(null);
  const [ocupado, setOcupado] = useState(false);

  const cambiar = useCallback(
    (cambios: Partial<BorradorAlta>) =>
      setBorrador((actual) => {
        const nuevo = { ...actual, ...cambios };
        almacen.guardar(nuevo);
        return nuevo;
      }),
    [almacen],
  );
  const paso = PASOS[indice];
  const seguir = () => {
    const falta = problemaEnPaso(paso, borrador);
    setProblema(falta);
    if (!falta) setIndice((i) => Math.min(i + 1, PASOS.length - 1));
  };
  const volver = () => (setProblema(null), setIndice((i) => Math.max(i - 1, 0)));
  const registrar = async (): Promise<string | null> => {
    setOcupado(true);
    setProblema(null);
    try {
      const { comercioId } = await repositorio.registrar(aDatosAlta(borrador));
      almacen.guardar(null);
      return comercioId;
    } catch (error) {
      setProblema(error instanceof Error ? error.message : 'No pudimos registrar tu negocio.');
      return null;
    } finally {
      setOcupado(false);
    }
  };
  return { paso, indice, borrador, cambiar, seguir, volver, registrar, problema, ocupado };
}
