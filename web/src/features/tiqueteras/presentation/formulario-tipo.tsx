'use client';

import { useState, type FormEvent } from 'react';
import { Aviso, Campo } from '@/shared/ui';
import { formatearPesos } from '@/shared/lib/moneda';
import type { DatosDeTipo, TipoDeTiquetera, Unidad } from '../domain/tiquetera';
import { Botones } from './botones';
import { Lista } from './lista';

export interface FormularioTipoProps {
  unidades: readonly Unidad[];
  actual: TipoDeTiquetera | null;
  ocupado: boolean;
  problema: string | null;
  alGuardar(datos: DatosDeTipo): void;
  alCancelar(): void;
}

type Borrador = Record<'nombre' | 'unidad' | 'unidades' | 'precio' | 'vigenciaDias', string>;

const numero = (texto: string) => Number(texto.replace(/[.\s$]/g, ''));

const borradorDe = (t: TipoDeTiquetera | null): Borrador => ({
  nombre: t?.nombre ?? '',
  unidad: t?.unidad.codigo ?? 'LUNCH',
  unidades: String(t?.unidades ?? ''),
  precio: String(t?.precio ?? ''),
  vigenciaDias: String(t?.vigenciaDias ?? 30),
});

function ayudaPrecio(b: Borrador): string | undefined {
  const porUnidad = numero(b.precio) / numero(b.unidades);
  if (!Number.isFinite(porUnidad) || porUnidad <= 0) return undefined;
  return `Sale a ${formatearPesos(Math.round(porUnidad))} cada una.`;
}

interface CamposProps {
  b: Borrador;
  cambiar(campo: keyof Borrador, valor: string): void;
  unidades: readonly Unidad[];
  vendido: boolean;
}

function Campos({ b, cambiar, unidades, vendido }: CamposProps) {
  const al = (campo: keyof Borrador) => (e: { target: { value: string } }) =>
    cambiar(campo, e.target.value);
  return (
    <div className="grid gap-m sm:grid-cols-2">
      <Campo
        etiqueta="Cantidad"
        inputMode="numeric"
        disabled={vendido}
        ayuda={vendido ? 'Ya se vendió: la cantidad queda como está.' : undefined}
        value={b.unidades}
        onChange={al('unidades')}
      />
      <Lista
        etiqueta="De qué"
        disabled={vendido}
        value={b.unidad}
        onChange={al('unidad')}
        opciones={unidades.map((u) => ({ valor: u.codigo, texto: u.plural }))}
      />
      <Campo
        etiqueta="Precio en pesos"
        inputMode="numeric"
        ayuda={ayudaPrecio(b)}
        value={b.precio}
        onChange={al('precio')}
      />
      <Campo
        etiqueta="Sirve por (días)"
        inputMode="numeric"
        ayuda="Cuenta desde el día de la compra."
        value={b.vigenciaDias}
        onChange={al('vigenciaDias')}
      />
    </div>
  );
}

/** Escribir un renglón de la pizarra. Si ya se vendió, la cantidad no se cambia. */
export function FormularioTipo({ unidades, actual, ...p }: FormularioTipoProps) {
  const [b, setB] = useState(() => borradorDe(actual));
  const cambiar = (campo: keyof Borrador, valor: string) => setB((v) => ({ ...v, [campo]: valor }));

  const enviar = (e: FormEvent) => {
    e.preventDefault();
    p.alGuardar({
      nombre: b.nombre,
      unidad: b.unidad,
      unidades: numero(b.unidades),
      precio: numero(b.precio),
      vigenciaDias: numero(b.vigenciaDias),
    });
  };

  return (
    <form
      onSubmit={enviar}
      aria-label={actual ? `Cambiar ${actual.nombre}` : 'Tiquetera nueva'}
      className="flex flex-col gap-m"
    >
      <Campo
        etiqueta="Nombre"
        placeholder="20 almuerzos"
        value={b.nombre}
        onChange={(e) => cambiar('nombre', e.target.value)}
      />
      <Campos b={b} cambiar={cambiar} unidades={unidades} vendido={(actual?.vendidas ?? 0) > 0} />
      {actual && (
        <p className="text-pequeno text-tinta-suave">
          Lo que ya vendiste sigue con su precio y su vencimiento.
        </p>
      )}
      {p.problema && <Aviso tono="error">{p.problema}</Aviso>}
      <Botones texto="Guardar en la pizarra" ocupado={p.ocupado} alCancelar={p.alCancelar} />
    </form>
  );
}
