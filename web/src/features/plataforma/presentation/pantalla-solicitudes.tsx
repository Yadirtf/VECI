'use client';

import { useCallback, useState } from 'react';
import { useCarga } from '@/shared/lib/use-carga';
import { Aviso } from '@/shared/ui';
import type { RepositorioPlataforma } from '../domain/solicitud';
import { TarjetaSolicitud } from './tarjeta-solicitud';

/**
 * Consola VECI: las solicitudes de negocio en revisión (ADR-0019). Aprobar crea el
 * negocio con quien lo pidió como propietaria; rechazar le cuenta por qué.
 */
export function PantallaSolicitudes({ repositorio }: { repositorio: RepositorioPlataforma }) {
  const cargar = useCallback(() => repositorio.pendientes(), [repositorio]);
  const { estado, recargar } = useCarga(cargar);
  const [hecho, setHecho] = useState<string | null>(null);

  if (estado.tipo === 'cargando')
    return <p className="text-cuerpo text-tinta-suave">Un momento, veci…</p>;
  if (estado.tipo === 'error') return <Aviso tono="error">{estado.mensaje}</Aviso>;

  const decidir = (aviso: string, accion: () => Promise<void>) => async () => {
    await accion();
    setHecho(aviso);
    recargar();
  };

  return (
    <section className="flex flex-col gap-m">
      {hecho && <Aviso tono="exito">{hecho}</Aviso>}
      {estado.datos.length === 0 ? (
        <p className="text-cuerpo text-tinta-suave">No hay solicitudes por revisar. ¡Al día!</p>
      ) : (
        estado.datos.map((s) => (
          <TarjetaSolicitud
            key={s.solicitudId}
            solicitud={s}
            alAprobar={decidir(`${s.nombre} ya está en VECI.`, () =>
              repositorio.aprobar(s.solicitudId),
            )}
            alRechazar={(motivo) =>
              decidir(`Le contamos a ${s.solicitante.nombre || 'la persona'} por qué.`, () =>
                repositorio.rechazar(s.solicitudId, motivo),
              )()
            }
          />
        ))
      )}
    </section>
  );
}
