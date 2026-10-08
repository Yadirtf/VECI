'use client';

import { useState, type FormEvent } from 'react';
import { Aviso, Campo } from '@/shared/ui';
import { formatearPesos } from '@/shared/lib/moneda';
import { armarPago, cantidad } from '../domain/reglas-tiqueteras';
import type { MedioDePago, Pago, TipoDeTiquetera } from '../domain/tiquetera';
import { Botones } from './botones';
import { Lista } from './lista';

export interface FormularioVentaProps {
  tipos: readonly TipoDeTiquetera[];
  medios: readonly MedioDePago[];
  ocupado: boolean;
  problema: string | null;
  alVender(tipo: TipoDeTiquetera, pago: Pago | string): void;
  alCancelar(): void;
}

interface TransferenciaProps {
  medio: MedioDePago;
  canal: string;
  referencia: string;
  alCanal(valor: string): void;
  alReferencia(valor: string): void;
}

function Transferencia({ medio, canal, referencia, alCanal, alReferencia }: TransferenciaProps) {
  return (
    <div className="grid gap-m sm:grid-cols-2">
      <Lista
        etiqueta="Por dónde"
        vacio="Elige"
        value={canal}
        onChange={(e) => alCanal(e.target.value)}
        opciones={medio.canales.map((c) => ({ valor: c.codigo, texto: c.nombre }))}
      />
      <Campo
        etiqueta="Referencia"
        ayuda="Opcional."
        maxLength={60}
        value={referencia}
        onChange={(e) => alReferencia(e.target.value)}
      />
    </div>
  );
}

const opcionDeTipo = (t: TipoDeTiquetera) => ({
  valor: t.tipoId,
  texto: `${t.nombre} · ${formatearPesos(t.precio)} · ${cantidad(t.unidades, t.unidad)} por ${t.vigenciaDias} días`,
});

const opcionDeMedio = (m: MedioDePago) => ({ valor: m.codigo, texto: m.nombre });

/** Vender desde la ficha: qué tiquetera y cómo pagó. El precio es el de la pizarra. */
export function FormularioVenta(props: FormularioVentaProps) {
  if (props.tipos.length === 0) {
    return (
      <Aviso tono="aviso">No hay tiqueteras en venta. Escríbelas primero en la pizarra.</Aviso>
    );
  }
  return <Venta {...props} />;
}

function Venta({ tipos, medios, ...p }: FormularioVentaProps) {
  const [tipoId, setTipoId] = useState(tipos[0]?.tipoId ?? '');
  const [medio, setMedio] = useState(medios[0]?.codigo ?? '');
  const [canal, setCanal] = useState('');
  const [referencia, setReferencia] = useState('');
  const tipo = tipos.find((t) => t.tipoId === tipoId) ?? tipos[0];
  const elegido = medios.find((m) => m.codigo === medio);

  const enviar = (e: FormEvent) => {
    e.preventDefault();
    p.alVender(tipo, armarPago(elegido, canal, referencia));
  };

  return (
    <form onSubmit={enviar} aria-label="Vender tiquetera" className="flex flex-col gap-m">
      <Lista
        etiqueta="Tiquetera"
        value={tipoId}
        onChange={(e) => setTipoId(e.target.value)}
        opciones={tipos.map(opcionDeTipo)}
      />
      <Lista
        etiqueta="Cómo pagó"
        value={medio}
        onChange={(e) => setMedio(e.target.value)}
        opciones={medios.map(opcionDeMedio)}
      />
      {elegido?.necesitaCanal && (
        <Transferencia
          medio={elegido}
          canal={canal}
          referencia={referencia}
          alCanal={setCanal}
          alReferencia={setReferencia}
        />
      )}
      {p.problema && <Aviso tono="error">{p.problema}</Aviso>}
      <Botones
        texto={`Cobrar ${formatearPesos(tipo.precio)}`}
        ocupado={p.ocupado}
        alCancelar={p.alCancelar}
      />
    </form>
  );
}
