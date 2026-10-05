'use client';

import Link from 'next/link';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import type { Espacio } from '../domain/sesion';

export interface SelectorComercioProps {
  nombre: string;
  negocios: readonly Espacio[];
  alElegir(comercioId: string): Promise<void>;
  alSalir(): Promise<void>;
}

const ENLACE_REGISTRO =
  'mt-l flex min-h-toque-boton items-center justify-center rounded-m bg-selva px-l text-subtitulo font-medio text-superficie hover:bg-selva-oscuro';

/** ¿Con cuál negocio vas a trabajar? Solo aparecen los que la persona administra. */
export function SelectorComercio({ nombre, negocios, alElegir, alSalir }: SelectorComercioProps) {
  const { ocupado, problema, ejecutar } = useAccion();

  if (negocios.length === 0) {
    return (
      <Tarjeta className="mx-auto w-full max-w-md">
        <h1 className="text-titulo font-fuerte text-tinta">Hola, {nombre}</h1>
        <p className="mt-s text-cuerpo text-tinta-suave">
          ¿Tienes un negocio? Regístralo en unos minutos y empieza a vender tiqueteras. Si eres
          cajero, usa la app VECI en el celular.
        </p>
        <Link href="/registrar" className={ENLACE_REGISTRO}>
          Registrar mi negocio
        </Link>
        <Boton variante="secundario" className="mt-m" onClick={() => void alSalir()}>
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
      <Link href="/registrar" className="mt-l inline-block font-medio text-selva-oscuro underline">
        Registrar otro negocio
      </Link>
      {problema && (
        <div className="mt-m">
          <Aviso tono="error">{problema}</Aviso>
        </div>
      )}
    </Tarjeta>
  );
}
