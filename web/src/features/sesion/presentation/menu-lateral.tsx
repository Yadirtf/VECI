'use client';

import Link from 'next/link';
import { Icono, type NombreIcono } from '@/shared/ui';

export interface ItemMenu {
  href: string;
  texto: string;
  icono: NombreIcono;
  /** Título del bloque del menú; los ítems seguidos con el mismo grupo van juntos. */
  grupo?: string;
}

export interface MenuLateralProps {
  negocio: string;
  nombre: string;
  menu: readonly ItemMenu[];
  ruta: string;
  puedeCambiarNegocio: boolean;
  alCambiarNegocio(): void;
  alSalir(): void;
  /** Solo en el cajón del celular: muestra la X para cerrarlo. */
  alCerrar?(): void;
}

export const FOCO =
  'focus-visible:outline-4 focus-visible:outline-offset-2 focus-visible:outline-maiz';

export const activa = (ruta: string, href: string) =>
  href === '/' ? ruta === '/' : ruta === href || ruta.startsWith(`${href}/`);

const inicial = (texto: string) => texto.trim().charAt(0).toLocaleUpperCase('es-CO') || 'V';

export const Marca = () => (
  <span className="font-[family-name:var(--font-letrero)] text-grande leading-none font-fuerte text-maiz">
    VECI
  </span>
);

/** Menú del panel: marca, negocio activo, opciones por bloque y la persona abajo. */
export function MenuLateral(p: MenuLateralProps) {
  return (
    <div className="flex h-full flex-col bg-selva-oscuro text-crema">
      <Cabecera alCerrar={p.alCerrar} />
      <NegocioActivo
        negocio={p.negocio}
        puedeCambiar={p.puedeCambiarNegocio}
        alCambiar={p.alCambiarNegocio}
      />
      <Opciones menu={p.menu} ruta={p.ruta} alCerrar={p.alCerrar} />
      <Persona nombre={p.nombre} alSalir={p.alSalir} />
    </div>
  );
}

function Cabecera({ alCerrar }: { alCerrar?(): void }) {
  return (
    <div className="flex items-center justify-between gap-s px-l pt-l pb-m lg:pt-m lg:pb-s">
      <Link href="/" className={`rounded-s ${FOCO}`}>
        <Marca />
        <span className="block text-pequeno text-crema/80 lg:sr-only">Tu vecino aliado</span>
      </Link>
      {alCerrar && (
        <button
          type="button"
          aria-label="Cerrar el menú"
          onClick={alCerrar}
          className={`inline-flex size-toque-minimo items-center justify-center rounded-m hover:bg-selva ${FOCO}`}
        >
          <Icono nombre="cerrar" tamano={26} />
        </button>
      )}
    </div>
  );
}

function NegocioActivo(p: { negocio: string; puedeCambiar: boolean; alCambiar(): void }) {
  return (
    <div className="mx-m rounded-m bg-selva/70 p-m lg:py-s shadow-[inset_0_0_0_1px_var(--color-selva)]">
      <div className="flex items-center gap-s">
        <span
          aria-hidden="true"
          className="inline-flex size-10 shrink-0 items-center justify-center rounded-total bg-maiz font-[family-name:var(--font-letrero)] text-subtitulo font-fuerte text-selva-oscuro"
        >
          {inicial(p.negocio)}
        </span>
        <div className="min-w-0">
          <p className="text-pequeno text-crema/80">Negocio</p>
          <p className="truncate font-medio" title={p.negocio}>
            {p.negocio}
          </p>
        </div>
      </div>
      {p.puedeCambiar && (
        <button
          type="button"
          onClick={p.alCambiar}
          className={`mt-s inline-flex min-h-toque-minimo w-full items-center justify-center gap-s rounded-s text-pequeno font-medio text-maiz hover:bg-selva-oscuro ${FOCO}`}
        >
          <Icono nombre="cambiar" tamano={18} />
          Cambiar de negocio
        </button>
      )}
    </div>
  );
}

function Opciones(p: { menu: readonly ItemMenu[]; ruta: string; alCerrar?(): void }) {
  return (
    <nav aria-label="Menú del panel" className="mt-m flex-1 lg:mt-s overflow-y-auto px-m pb-m">
      {agrupar(p.menu).map(({ grupo, items }, i) => (
        <div key={grupo ?? i} className="mt-s first:mt-0">
          {grupo && (
            <p className="px-s pt-s pb-xs text-pequeno lg:pt-xs font-medio tracking-wide text-crema/70">
              {grupo}
            </p>
          )}
          <ul className="flex flex-col gap-xs">
            {items.map((item) => (
              <li key={item.href}>
                <Opcion item={item} aqui={activa(p.ruta, item.href)} alCerrar={p.alCerrar} />
              </li>
            ))}
          </ul>
        </div>
      ))}
    </nav>
  );
}

/** La opción de la página actual queda en papel crema con la marca de maíz al borde. */
function Opcion({ item, aqui, alCerrar }: { item: ItemMenu; aqui: boolean; alCerrar?(): void }) {
  return (
    <Link
      href={item.href}
      aria-current={aqui ? 'page' : undefined}
      onClick={aqui ? alCerrar : undefined}
      className={`relative flex min-h-toque-minimo items-center gap-m lg:min-h-11 rounded-s px-s font-medio transition-colors ${FOCO} ${
        aqui
          ? 'bg-crema text-selva-oscuro before:absolute before:inset-y-s before:-left-m before:w-1.5 before:rounded-r-s before:bg-maiz'
          : 'text-crema hover:bg-selva'
      }`}
    >
      <Icono nombre={item.icono} tamano={22} className="shrink-0" />
      <span className="truncate">{item.texto}</span>
    </Link>
  );
}

function Persona({ nombre, alSalir }: { nombre: string; alSalir(): void }) {
  return (
    <div className="flex items-center gap-s border-t border-selva px-m py-m lg:py-s">
      <span
        aria-hidden="true"
        className="inline-flex size-10 shrink-0 items-center justify-center rounded-total bg-crema font-fuerte text-selva-oscuro"
      >
        {inicial(nombre)}
      </span>
      <p className="min-w-0 flex-1 truncate">
        Hola, <span className="font-medio">{nombre}</span>
      </p>
      <button
        type="button"
        onClick={alSalir}
        className={`inline-flex min-h-toque-minimo shrink-0 items-center gap-xs rounded-s px-s font-medio hover:bg-selva ${FOCO}`}
      >
        <Icono nombre="salir" tamano={20} />
        Salir
      </button>
    </div>
  );
}

function agrupar(menu: readonly ItemMenu[]) {
  const grupos: { grupo?: string; items: ItemMenu[] }[] = [];
  for (const item of menu) {
    const ultimo = grupos[grupos.length - 1];
    if (ultimo && ultimo.grupo === item.grupo) ultimo.items.push(item);
    else grupos.push({ grupo: item.grupo, items: [item] });
  }
  return grupos;
}
