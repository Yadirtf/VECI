'use client';

import Link from 'next/link';
import { useCallback } from 'react';
import { Aviso, Boton } from '@/shared/ui';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import type { CodigoPaso, Perfil, RepositorioComercios } from '../domain/comercio';
import { SelloNegocio } from './sello';

const PASOS: Record<CodigoPaso, { texto: string; enlace?: string; falta: string }> = {
  DATOS: { texto: 'Tus datos', enlace: '/negocio', falta: 'Revisa nombre, celular y logo.' },
  HORARIOS: { texto: 'Horarios', enlace: '/horarios', falta: 'Dinos a qué horas atiendes.' },
  EQUIPO: { texto: 'Tu equipo', enlace: '/equipo', falta: 'Invita a quien te ayuda en caja.' },
  TIQUETERAS: { texto: 'Tiqueteras', falta: 'Muy pronto armas tus tiqueteras aquí.' },
};

/** Un sendero que serpentea; cada paso es una parada y el negocio abierto, la meta. */
const PARADAS = [
  { x: 60, y: 70 },
  { x: 190, y: 30 },
  { x: 320, y: 80 },
  { x: 450, y: 35 },
];
const SENDERO =
  'M 10 90 C 40 70, 40 60, 60 70 S 150 20, 190 30 S 280 100, 320 80 S 400 20, 450 35 S 520 60, 560 50';

function fecha(iso: string): string {
  return new Date(`${iso}T12:00:00`).toLocaleDateString('es-CO', { day: 'numeric', month: 'long' });
}

function Parada({ paso, x, y }: { paso: Perfil['camino'][number]; x: number; y: number }) {
  const borde = paso.obligatorio && !paso.listo ? 'var(--color-arcilla)' : 'var(--color-borde)';
  return (
    <g transform={`translate(${x} ${y})`}>
      <circle
        r={paso.listo ? 16 : 13}
        fill={paso.listo ? 'var(--color-maiz)' : 'var(--color-superficie)'}
        stroke={borde}
        strokeWidth={3}
      />
      {paso.listo && (
        <path
          d="M -6 0 L -1 5 L 7 -5"
          stroke="var(--color-selva-oscuro)"
          strokeWidth={3}
          fill="none"
          strokeLinecap="round"
        />
      )}
    </g>
  );
}

function Sendero({ perfil }: { perfil: Perfil }) {
  return (
    <svg
      viewBox="0 0 580 120"
      className="w-full"
      role="img"
      aria-label="Camino para abrir tu negocio"
    >
      <path
        d={SENDERO}
        fill="none"
        stroke="var(--color-arcilla-claro)"
        strokeWidth={22}
        strokeLinecap="round"
      />
      <path
        d={SENDERO}
        fill="none"
        stroke="var(--color-arcilla)"
        strokeWidth={2}
        strokeDasharray="2 10"
        strokeLinecap="round"
      />
      {perfil.camino.map((paso, i) => (
        <Parada key={paso.codigo} paso={paso} {...PARADAS[i]} />
      ))}
      <path
        transform="translate(548 18)"
        d="M 0 32 L 0 0 L 22 8 L 0 16"
        fill={perfil.abierto ? 'var(--color-selva)' : 'var(--color-borde)'}
      />
    </svg>
  );
}

function Paradas({ perfil }: { perfil: Perfil }) {
  return (
    <ol className="grid gap-m sm:grid-cols-4">
      {perfil.camino.map((paso, i) => {
        const info = PASOS[paso.codigo];
        const contenido = (
          <>
            <span className="text-subtitulo font-fuerte text-selva-oscuro">{info.texto}</span>
            <span className="text-cuerpo text-tinta-suave">
              {paso.listo ? 'Listo' : info.falta}
              {paso.obligatorio && !paso.listo && ' Este sí hace falta para abrir.'}
            </span>
          </>
        );
        return (
          <li key={paso.codigo} className={`flex flex-col gap-xs ${i % 2 ? 'sm:mt-l' : ''}`}>
            {info.enlace ? (
              <Link
                href={info.enlace}
                className="flex flex-col gap-xs rounded-m p-s hover:bg-selva-claro"
              >
                {contenido}
              </Link>
            ) : (
              <div className="flex flex-col gap-xs p-s">{contenido}</div>
            )}
          </li>
        );
      })}
    </ol>
  );
}

/**
 * Inicio del panel recién registrado el negocio: un sendero con las paradas que faltan
 * para abrir (HU-03-01). Abrir solo exige los pasos obligatorios; los demás esperan.
 */
export function CaminoDeApertura({ repositorio }: { repositorio: RepositorioComercios }) {
  const cargar = useCallback(() => repositorio.perfil(), [repositorio]);
  const { estado, recargar } = useCarga(cargar);
  const { ocupado, problema, ejecutar } = useAccion();
  if (estado.tipo === 'cargando')
    return <p className="text-cuerpo text-tinta-suave">Un momento, veci…</p>;
  if (estado.tipo === 'error') return <Aviso tono="error">{estado.mensaje}</Aviso>;
  const perfil = estado.datos;
  return (
    <section className="flex flex-col gap-l">
      <header className="flex flex-wrap items-center gap-l">
        <SelloNegocio nombre={perfil.nombre} logoUrl={perfil.logoUrl} tamano={84} />
        <div>
          <h1 className="text-grande font-fuerte leading-tight text-selva-oscuro">
            {perfil.abierto ? `¡${perfil.nombre} está abierto!` : `Vamos abriendo ${perfil.nombre}`}
          </h1>
          {perfil.plan && (
            <p className="text-cuerpo text-tinta-suave">
              Plan {perfil.plan.nombre} hasta el {fecha(perfil.plan.venceEl)}.
            </p>
          )}
        </div>
      </header>
      <Sendero perfil={perfil} />
      <Paradas perfil={perfil} />
      {problema && <Aviso tono="aviso">{problema}</Aviso>}
      {!perfil.abierto && (
        <Boton
          grande
          disabled={!perfil.puedeAbrir || ocupado}
          className="self-start"
          onClick={() =>
            void ejecutar(async () => {
              await repositorio.abrir();
              recargar();
            })
          }
        >
          {perfil.puedeAbrir ? 'Abrir mi negocio' : 'Primero los horarios'}
        </Boton>
      )}
    </section>
  );
}
