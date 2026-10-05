'use client';

import type { ClienteEnLibreta } from '../domain/cliente';
import { TEXTO_CUENTA, type FiltroClientes } from '../domain/reglas-clientes';

const FILTROS: ReadonlyArray<[FiltroClientes, string]> = [
  ['TODOS', 'Todos'],
  ['SIN_APP', 'Sin app aún'],
];

export interface FiltrosProps {
  filtro: FiltroClientes;
  alCambiar(filtro: FiltroClientes): void;
}

/** "Todos" / "Sin app aún" como piedras pequeñas que se quedan presionadas. */
export function Filtros({ filtro, alCambiar }: FiltrosProps) {
  return (
    <div role="group" aria-label="Filtrar clientes" className="flex flex-wrap gap-s">
      {FILTROS.map(([valor, texto]) => (
        <button
          key={valor}
          type="button"
          aria-pressed={filtro === valor}
          onClick={() => alCambiar(valor)}
          className={`piedra min-h-toque-minimo px-l text-cuerpo font-medio focus-visible:outline-4 focus-visible:outline-maiz ${
            filtro === valor
              ? 'bg-selva-oscuro text-crema'
              : 'bg-superficie text-selva-oscuro shadow-[inset_0_0_0_2px_var(--color-selva)]'
          }`}
        >
          {texto}
        </button>
      ))}
    </div>
  );
}

export interface RenglonesProps {
  clientes: readonly ClienteEnLibreta[];
  elegido: string | null;
  alElegir(clienteId: string): void;
}

/** Los renglones de la libreta: nombre, documento tapado y si usa la app. */
export function Renglones({ clientes, elegido, alElegir }: RenglonesProps) {
  return (
    <ul aria-label="Clientes" className="flex flex-col divide-y-2 divide-dashed divide-borde">
      {clientes.map((c) => {
        const aqui = c.clienteId === elegido;
        return (
          <li key={c.clienteId}>
            <button
              type="button"
              aria-current={aqui ? 'true' : undefined}
              onClick={() => alElegir(c.clienteId)}
              className={`flex w-full flex-col items-start gap-xs px-m py-s text-left focus-visible:outline-4 focus-visible:outline-maiz ${
                aqui ? 'bg-selva-claro' : 'hover:bg-crema'
              }`}
            >
              <span className="text-subtitulo font-medio text-tinta">{c.nombre}</span>
              <span className="text-pequeno text-tinta-suave">
                Doc. {c.documento}
                {c.celular ? ` · Cel. ${c.celular}` : ''} · {TEXTO_CUENTA[c.cuenta]}
              </span>
            </button>
          </li>
        );
      })}
    </ul>
  );
}
