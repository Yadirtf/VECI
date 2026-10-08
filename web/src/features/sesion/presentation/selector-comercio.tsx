'use client';

import Link from 'next/link';
import type { ReactNode } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import type { Espacio } from '../domain/sesion';

export interface SelectorComercioProps {
  nombre: string;
  negocios: readonly Espacio[];
  /** Del equipo VECI con permiso para revisar solicitudes de negocio. */
  esEquipoVeci?: boolean;
  alElegir(comercioId: string): Promise<void>;
  alSalir(): Promise<void>;
}

const ENLACE_REGISTRO =
  'mt-l flex min-h-toque-boton items-center justify-center rounded-m bg-selva px-l text-subtitulo font-medio text-superficie hover:bg-selva-oscuro';

/** Aún no administra ningún negocio: puede pedir registrar el suyo. */
function SinNegocios(p: { nombre: string; alSalir(): Promise<void>; consola: ReactNode }) {
  return (
    <Tarjeta className="mx-auto w-full max-w-md">
      <h1 className="text-titulo font-fuerte text-tinta">Hola, {p.nombre}</h1>
      <p className="mt-s text-cuerpo text-tinta-suave">
        ¿Tienes un negocio? Cuéntanos de él en unos minutos y el equipo VECI lo revisa para que
        empieces a vender tiqueteras. Si eres cajero, usa la app VECI en el celular.
      </p>
      <Link href="/registrar" className={ENLACE_REGISTRO}>
        Solicitar el registro de mi negocio
      </Link>
      {p.consola}
      <Boton variante="secundario" className="mt-m" onClick={() => void p.alSalir()}>
        Salir
      </Boton>
    </Tarjeta>
  );
}

/** ¿Con cuál negocio vas a trabajar? Solo aparecen los que la persona administra. */
export function SelectorComercio(p: SelectorComercioProps) {
  const { nombre, negocios, alElegir, alSalir } = p;
  const { ocupado, problema, ejecutar } = useAccion();
  const consola = p.esEquipoVeci && (
    <Link href="/plataforma" className="mt-m inline-block font-medio text-selva-oscuro underline">
      Consola VECI: solicitudes de negocio
    </Link>
  );

  if (negocios.length === 0)
    return <SinNegocios nombre={nombre} alSalir={alSalir} consola={consola} />;

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
        Solicitar el registro de otro negocio
      </Link>
      {consola && <div>{consola}</div>}
      {problema && (
        <div className="mt-m">
          <Aviso tono="error">{problema}</Aviso>
        </div>
      )}
    </Tarjeta>
  );
}
