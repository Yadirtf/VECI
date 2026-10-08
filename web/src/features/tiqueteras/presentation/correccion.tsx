'use client';

import { useState, type FormEvent } from 'react';
import { Aviso, Campo } from '@/shared/ui';
import type { Correccion, Motivo } from '../domain/tiquetera';
import { Botones } from './botones';
import { Lista } from './lista';

export interface FormularioCorreccionProps {
  titulo: string;
  motivos: readonly Motivo[];
  /** Ajuste: pide cuántas unidades suma o quita. */
  conUnidades?: boolean;
  textoBoton: string;
  ocupado: boolean;
  problema: string | null;
  alEnviar(correccion: Correccion, unidades: number): void;
  alCancelar(): void;
}

/**
 * La enmendadura: toda corrección dice por qué y queda a la vista en la historia,
 * nunca se borra lo anterior (HU-05-05).
 */
export function FormularioCorreccion(p: FormularioCorreccionProps) {
  const [motivo, setMotivo] = useState('');
  const [nota, setNota] = useState('');
  const [unidades, setUnidades] = useState('');

  const enviar = (e: FormEvent) => {
    e.preventDefault();
    p.alEnviar({ motivo, nota: nota.trim() || null }, Number(unidades));
  };

  return (
    <form
      onSubmit={enviar}
      aria-label={p.titulo}
      className="flex flex-col gap-m border-l-4 border-arcilla bg-arcilla-claro p-m"
    >
      <p className="text-subtitulo font-fuerte text-arcilla-oscuro">{p.titulo}</p>
      {p.conUnidades && (
        <Campo
          etiqueta="Unidades"
          ayuda="Positivo suma (3), negativo quita (-2)."
          inputMode="numeric"
          value={unidades}
          onChange={(e) => setUnidades(e.target.value)}
        />
      )}
      <Lista
        etiqueta="Motivo"
        vacio="Elige el motivo"
        value={motivo}
        onChange={(e) => setMotivo(e.target.value)}
        opciones={p.motivos.map((m) => ({ valor: m.codigo, texto: m.nombre }))}
      />
      <Campo
        etiqueta="Nota"
        ayuda={motivo === 'OTHER' ? 'Obligatoria con «Otro».' : 'Opcional.'}
        maxLength={500}
        value={nota}
        onChange={(e) => setNota(e.target.value)}
      />
      {p.problema && <Aviso tono="error">{p.problema}</Aviso>}
      <Botones
        texto={p.textoBoton}
        ocupado={p.ocupado}
        variante="peligro"
        alCancelar={p.alCancelar}
      />
    </form>
  );
}
