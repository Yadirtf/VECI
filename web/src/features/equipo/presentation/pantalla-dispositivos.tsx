'use client';

import { useCallback, useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import type { Dispositivo, RepositorioEquipo } from '../domain/equipo';
import { cuantoHace, ordenarDispositivos } from '../domain/reglas-equipo';

const PLATAFORMA: Record<string, string> = {
  ANDROID: 'Celular Android',
  IOS: 'iPhone',
  WEB: 'Navegador',
};
const nombreDe = (d: Dispositivo) => d.nombre ?? PLATAFORMA[d.plataforma] ?? 'Dispositivo';

function mensajeDeCierre(cerradas: number, d: Dispositivo): string {
  if (cerradas === 0) return 'Ese dispositivo ya no tenía sesiones abiertas.';
  const cuantas = cerradas === 1 ? 'la sesión' : `${cerradas} sesiones`;
  return `Listo. Cerramos ${cuantas} en ${nombreDe(d)}.`;
}

export interface PantallaDispositivosProps {
  repositorio: RepositorioEquipo;
  ahora?: () => Date;
}

/** Celulares y computadores con sesión en el negocio; cierre a distancia (HU-02-06). */
export function PantallaDispositivos({
  repositorio,
  ahora = () => new Date(),
}: PantallaDispositivosProps) {
  const listar = useCallback(() => repositorio.dispositivos(), [repositorio]);
  const { estado, recargar } = useCarga(listar);
  const { ocupado, problema, ejecutar } = useAccion();
  const [aviso, setAviso] = useState<string | null>(null);

  const cerrar = (d: Dispositivo) =>
    void ejecutar(async () => {
      setAviso(mensajeDeCierre(await repositorio.cerrarSesiones(d.dispositivoId), d));
      recargar();
    });

  if (estado.tipo === 'cargando') return <Aviso tono="aviso">Un momento, veci…</Aviso>;
  if (estado.tipo === 'error') return <Aviso tono="error">{estado.mensaje}</Aviso>;
  return (
    <div className="flex flex-col gap-m">
      {aviso && <Aviso tono="exito">{aviso}</Aviso>}
      {problema && <Aviso tono="error">{problema}</Aviso>}
      {estado.datos.length === 0 && (
        <Aviso tono="aviso">Aún nadie ha entrado desde la app de la caja.</Aviso>
      )}
      {ordenarDispositivos(estado.datos).map((d) => (
        <TarjetaDispositivo
          key={d.dispositivoId}
          dispositivo={d}
          ahora={ahora()}
          ocupado={ocupado}
          alCerrar={() => cerrar(d)}
        />
      ))}
    </div>
  );
}

function TarjetaDispositivo(p: {
  dispositivo: Dispositivo;
  ahora: Date;
  ocupado: boolean;
  alCerrar(): void;
}) {
  const d = p.dispositivo;
  return (
    <Tarjeta aria-label={nombreDe(d)} className="flex flex-col gap-s">
      <h3 className="text-titulo font-fuerte text-tinta">{nombreDe(d)}</h3>
      <p className="text-cuerpo text-tinta-suave">
        Usado por última vez {cuantoHace(d.ultimaVez, p.ahora)}
      </p>
      {d.sesiones.length === 0 ? (
        <p className="text-cuerpo">Sin sesiones abiertas.</p>
      ) : (
        <>
          <ul className="text-cuerpo">
            {d.sesiones.map((s) => (
              <li key={s.sesionId}>
                {s.nombre} · {cuantoHace(s.ultimoUso, p.ahora)}
              </li>
            ))}
          </ul>
          <Boton variante="peligro" disabled={p.ocupado} onClick={p.alCerrar}>
            Cerrar sesión en este dispositivo
          </Boton>
        </>
      )}
    </Tarjeta>
  );
}
