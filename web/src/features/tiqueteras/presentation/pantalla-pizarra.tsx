'use client';

import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import { formatearPesos } from '@/shared/lib/moneda';
import { usePizarra } from '../application/use-pizarra';
import { cantidad } from '../domain/reglas-tiqueteras';
import type { RepositorioPizarra, TipoDeTiquetera } from '../domain/tiquetera';
import { FormularioTipo } from './formulario-tipo';

type Pizarra = ReturnType<typeof usePizarra>;

/** Un renglón escrito con tiza; el que no se vende queda borroso, como medio borrado. */
function Renglon({ tipo, p }: { tipo: TipoDeTiquetera; p: Pizarra }) {
  const activo = tipo.estado === 'ACTIVE';
  return (
    <li
      className={`flex flex-wrap items-center justify-between gap-m border-b border-dashed border-selva-claro/40 py-m ${activo ? '' : 'opacity-60'}`}
    >
      <div className="flex flex-col gap-xs">
        <p className={`text-titulo font-fuerte ${activo ? '' : 'line-through decoration-2'}`}>
          {tipo.nombre}
        </p>
        <p className="text-cuerpo">
          {cantidad(tipo.unidades, tipo.unidad)} · {formatearPesos(tipo.precio)} · sirve{' '}
          {tipo.vigenciaDias} {tipo.vigenciaDias === 1 ? 'día' : 'días'}
        </p>
        <p className="text-pequeno">
          {formatearPesos(tipo.precioPorUnidad)} cada {tipo.unidad.singular} · {tipo.vendidas}{' '}
          vendidas · {tipo.vigentes} vigentes{activo ? '' : ' · no se vende'}
        </p>
      </div>
      <div className="flex flex-wrap gap-s">
        <Boton
          variante="secundario"
          disabled={p.ocupado}
          onClick={() => p.editar({ tipo: 'editar', actual: tipo })}
        >
          Cambiar
        </Boton>
        <Boton variante="secundario" disabled={p.ocupado} onClick={() => p.alternar(tipo)}>
          {activo ? 'Dejar de vender' : 'Volver a vender'}
        </Boton>
      </div>
    </li>
  );
}

function Tablero({ tipos, p }: { tipos: TipoDeTiquetera[]; p: Pizarra }) {
  return (
    <section
      aria-label="Pizarra de tiqueteras"
      className="rounded-m border-8 border-arcilla-oscuro bg-selva-oscuro px-l py-m text-superficie shadow-[6px_6px_0_var(--color-sombra-papel)]"
    >
      {tipos.length === 0 ? (
        <p className="py-l text-cuerpo">
          La pizarra está limpia. Escribe tu primera tiquetera, por ejemplo «20 almuerzos por
          $220.000».
        </p>
      ) : (
        <ul>
          {tipos.map((t) => (
            <Renglon key={t.tipoId} tipo={t} p={p} />
          ))}
        </ul>
      )}
    </section>
  );
}

/** La pizarra del negocio: lo que se vende, a cuánto y por cuánto tiempo (HU-05-01). */
export function PantallaPizarra({ repositorio }: { repositorio: RepositorioPizarra }) {
  const p = usePizarra(repositorio);
  if (p.estado.tipo === 'cargando')
    return <Aviso tono="aviso">Un momento, veci, ya traemos la pizarra…</Aviso>;
  if (p.estado.tipo === 'error') return <Aviso tono="error">{p.estado.mensaje}</Aviso>;
  const { tipos, unidades } = p.estado.datos;
  const e = p.edicion;
  return (
    <div className="flex flex-col gap-l">
      <div className="flex flex-wrap items-center justify-between gap-m">
        <p className="text-subtitulo text-tinta-suave">
          La caja solo vende lo que está en la pizarra. Dejar de vender uno no toca lo ya vendido.
        </p>
        <Boton onClick={() => p.editar({ tipo: 'nuevo' })}>Escribir tiquetera</Boton>
      </div>
      {p.aviso && <Aviso tono="exito">{p.aviso}</Aviso>}
      {e.tipo !== 'nada' && (
        <Tarjeta perforado>
          <FormularioTipo
            key={e.tipo === 'editar' ? e.actual.tipoId : 'nuevo'}
            unidades={unidades}
            actual={e.tipo === 'editar' ? e.actual : null}
            ocupado={p.ocupado}
            problema={p.problema}
            alGuardar={p.guardar}
            alCancelar={() => p.editar({ tipo: 'nada' })}
          />
        </Tarjeta>
      )}
      {e.tipo === 'nada' && p.problema && <Aviso tono="error">{p.problema}</Aviso>}
      <Tablero tipos={tipos} p={p} />
    </div>
  );
}
