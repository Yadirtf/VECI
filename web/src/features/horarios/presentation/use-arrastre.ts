'use client';

import { useRef, type PointerEvent, type RefObject } from 'react';
import type { Punto } from '../domain/arco';

/**
 * Arrastrar un punto dentro de un SVG con dedo o ratón: convierte la posición de la
 * pantalla a coordenadas del dibujo y avisa mientras se mueve.
 */
export function useArrastre(svg: RefObject<SVGSVGElement | null>, alMover: (p: Punto) => void) {
  const activo = useRef(false);
  const aDibujo = (e: PointerEvent): Punto | null => {
    const matriz = svg.current?.getScreenCTM()?.inverse();
    if (!matriz) return null;
    const p = new DOMPoint(e.clientX, e.clientY).matrixTransform(matriz);
    return { x: p.x, y: p.y };
  };
  return {
    onPointerDown: (e: PointerEvent<SVGElement>) => {
      activo.current = true;
      e.currentTarget.setPointerCapture(e.pointerId);
    },
    onPointerMove: (e: PointerEvent<SVGElement>) => {
      const p = activo.current ? aDibujo(e) : null;
      if (p) alMover(p);
    },
    onPointerUp: () => {
      activo.current = false;
    },
  };
}
