'use client';

import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import type { Espacio } from '../domain/sesion';

export interface SelectorComercioProps {
  nombre: string;
  negocios: readonly Espacio[];
  alElegir(comercioId: string): Promise<void>;
  alSalir(): Promise<void>;
}

/** ¿Con cuál negocio vas a trabajar? Solo aparecen los que la persona administra. */
export function SelectorComercio({ nombre, negocios, alElegir, alSalir }: SelectorComercioProps) {
  const { ocupado, problema, ejecutar } = useAccion();

  if (negocios.length === 0) {
    return (
      <Tarjeta className="mx-auto w-full max-w-md">
        <h1 className="text-titulo font-fuerte text-tinta">Hola, {nombre}</h1>
        <p className="mt-s text-cuerpo text-tinta-suave">
          El panel es para quien administra el negocio. Para la caja, usa la app VECI en el celular.
        </p>
        <Boton variante="secundario" className="mt-l" onClick={() => void alSalir()}>
          Salir
        </Boton>
      </Tarjeta>
    );
  }

  return (
    <Tarjeta className="mx-auto w-full max-w-md">
      <h1 className="text-titulo font-fuerte text-tinta">Hola, {nombre}</h1>
      <p className="mt-xs text-cuerpo text-tinta-suave">¿Con cuál negocio vas a trabajar?</p>
      <ul className="mt-l flex flex-col gap-s">
        {negocios.map((n) => (
          <li key={n.comercioId}>
            <Boton
              variante="secundario"
              className="w-full text-left"
              disabled={ocupado}
              onClick={() => void ejecutar(() => alElegir(n.comercioId))}
            >
              {n.nombre}
            </Boton>
          </li>
        ))}
      </ul>
      {problema && (
        <div className="mt-m">
          <Aviso tono="error">{problema}</Aviso>
        </div>
      )}
    </Tarjeta>
  );
}
