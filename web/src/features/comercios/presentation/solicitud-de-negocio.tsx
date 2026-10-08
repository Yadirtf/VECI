'use client';

import Link from 'next/link';
import { useCallback, useState } from 'react';
import { Aviso, Tarjeta } from '@/shared/ui';
import { useCarga } from '@/shared/lib/use-carga';
import type { useAlta } from '../application/use-alta';
import type { Solicitud } from '../domain/comercio';
import { AltaConversada, type CatalogosAlta } from './alta-conversada';

interface Props {
  alta: ReturnType<typeof useAlta>;
  cargarCatalogos(): Promise<CatalogosAlta>;
  misSolicitudes(): Promise<Solicitud[]>;
}

/** La solicitud ya llegó: VECI la revisa y le avisa a la persona. */
export function SolicitudEnRevision({ nombre }: { nombre: string }) {
  return (
    <Tarjeta className="mx-auto w-full max-w-[36rem]">
      <h2 className="text-titulo font-fuerte text-tinta">Recibimos tu solicitud, veci</h2>
      <p className="mt-s text-cuerpo text-tinta-suave">
        El equipo VECI está revisando los datos de <strong>{nombre}</strong>. Apenas la aprobemos,
        tu negocio aparece aquí y en la app para que lo configures y empieces a vender.
      </p>
      <Link href="/" className="mt-l inline-block font-medio text-selva-oscuro underline">
        Volver
      </Link>
    </Tarjeta>
  );
}

/**
 * Pedir el registro del negocio (ADR-0019): si ya hay una solicitud en revisión se
 * muestra su estado; si la última fue rechazada, el motivo va antes de la conversación.
 */
export function SolicitudDeNegocio({ alta, cargarCatalogos, misSolicitudes }: Props) {
  const { estado } = useCarga(misSolicitudes);
  const [enviada, setEnviada] = useState<string | null>(null);
  const alEnviar = useCallback(() => setEnviada(alta.borrador.nombre.trim()), [alta.borrador]);

  if (enviada) return <SolicitudEnRevision nombre={enviada} />;
  if (estado.tipo === 'cargando')
    return <p className="text-cuerpo text-tinta-suave">Un momento, veci…</p>;
  if (estado.tipo === 'error') return <Aviso tono="error">{estado.mensaje}</Aviso>;
  const pendiente = estado.datos.find((s) => s.estado === 'PENDING');
  if (pendiente) return <SolicitudEnRevision nombre={pendiente.nombre} />;
  const ultima = estado.datos[0];
  return (
    <>
      {ultima?.estado === 'REJECTED' && (
        <div className="mx-auto w-full max-w-[36rem]">
          <Aviso tono="aviso">
            No pudimos aprobar «{ultima.nombre}»: {ultima.nota} Corrige lo que haga falta y vuelve a
            enviarla.
          </Aviso>
        </div>
      )}
      <AltaConversada alta={alta} cargarCatalogos={cargarCatalogos} alEnviar={alEnviar} />
    </>
  );
}
