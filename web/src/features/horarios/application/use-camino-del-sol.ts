'use client';

import { useCallback, useMemo, useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import { DIAS } from '../domain/agrupar-por-dia';
import { aHora, aMinutos } from '../domain/arco';
import { limitesDe, moverExtremo, type Extremo } from '../domain/dia-de-servicio';
import type { Horario, RepositorioHorarios, SedeCorta, Servicio } from '../domain/horario';

export interface DatosHorarios {
  horarios: Horario[];
  servicios: Servicio[];
  sedes: SedeCorta[];
}

type Rango = { inicio: number; fin: number };

/** Código del día de hoy: la pantalla abre en el sol de hoy. */
export function diaDeHoy(fecha = new Date()): string {
  return DIAS[(fecha.getDay() + 6) % 7][0];
}

function useDatos(repositorio: RepositorioHorarios) {
  const cargar = useCallback(async (): Promise<DatosHorarios> => {
    const [horarios, servicios, sedes] = await Promise.all([
      repositorio.listar(),
      repositorio.servicios(),
      repositorio.sedes(),
    ]);
    return { horarios, servicios, sedes };
  }, [repositorio]);
  return useCarga(cargar);
}

/** Lo que se está moviendo con el dedo antes de guardarlo. */
function useBorrador(horarios: Horario[]) {
  const [elegidoId, setElegidoId] = useState<string | null>(null);
  const [rango, setRango] = useState<Rango | null>(null);
  const elegido = horarios.find((h) => h.id === elegidoId) ?? null;
  const elegir = (h: Horario | null) => {
    setElegidoId(h?.id ?? null);
    setRango(h ? { inicio: aMinutos(h.horaInicio), fin: aMinutos(h.horaFin) } : null);
  };
  const mover = (extremo: Extremo, minutos: number) => {
    if (!elegido || !rango) return;
    setRango(moverExtremo(rango, extremo, minutos, limitesDe(horarios, elegido)));
  };
  const cambiado =
    !!elegido &&
    !!rango &&
    (aHora(rango.inicio) !== elegido.horaInicio || aHora(rango.fin) !== elegido.horaFin);
  return { elegido, rango, elegir, mover, cambiado, setElegidoId };
}

/**
 * Caso de uso "ajustar el día de servicio" (HU-03-02): elegir un día y una sede,
 * estirar un servicio, guardarlo, pausarlo o copiarlo a otros días.
 */
export function useCaminoDelSol(repositorio: RepositorioHorarios) {
  const { estado, recargar } = useDatos(repositorio);
  const [dia, setDia] = useState(diaDeHoy);
  const [sedeElegida, setSede] = useState<string | null>(null);
  const accion = useAccion();
  const datos = estado.tipo === 'listo' ? estado.datos : null;
  const sedeId = sedeElegida ?? datos?.sedes[0]?.id ?? null;
  const deLaSede = useMemo(
    () => datos?.horarios.filter((h) => h.sedeId === sedeId) ?? [],
    [datos, sedeId],
  );
  const delDia = deLaSede.filter((h) => h.dia === dia);
  const borrador = useBorrador(deLaSede);
  const hecho = (f: () => Promise<void>) => accion.ejecutar(async () => (await f(), recargar()));
  const acciones = useAcciones(repositorio, borrador, hecho);
  const elegirDia = (codigo: string) => (setDia(codigo), borrador.elegir(null));
  return {
    estado,
    datos,
    dia,
    elegirDia,
    sedeId,
    setSede,
    deLaSede,
    delDia,
    borrador,
    accion,
    ...acciones,
  };
}

type Borrador = ReturnType<typeof useBorrador>;
type Hecho = (f: () => Promise<void>) => Promise<boolean>;

function useAcciones(repositorio: RepositorioHorarios, b: Borrador, hecho: Hecho) {
  const guardar = () =>
    hecho(async () => {
      if (!b.elegido || !b.rango) return;
      b.setElegidoId(
        await repositorio.editar(b.elegido.id, aHora(b.rango.inicio), aHora(b.rango.fin)),
      );
    });
  const pausar = (h: Horario) => hecho(() => repositorio.cambiarEstado(h.id, !h.activo));
  const copiar = (h: Horario, dias: string[]) =>
    hecho(() =>
      repositorio.crear({
        servicioId: h.servicioId,
        sedeId: h.sedeId,
        dias,
        horaInicio: h.horaInicio,
        horaFin: h.horaFin,
      }),
    );
  const crear = (servicio: Servicio | string, sedeId: string, dias: string[], rango: Rango) =>
    hecho(async () => {
      const { id } =
        typeof servicio === 'string' ? await repositorio.crearServicio(servicio) : servicio;
      await repositorio.crear({
        servicioId: id,
        sedeId,
        dias,
        horaInicio: aHora(rango.inicio),
        horaFin: aHora(rango.fin),
      });
    });
  return { guardar, pausar, copiar, crear };
}
