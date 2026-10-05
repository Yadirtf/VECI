'use client';

import { useCallback } from 'react';
import { useCarga } from '@/shared/lib/use-carga';
import { Aviso, Boton } from '@/shared/ui';
import type { FuentePolitica, SeccionPolitica } from '../domain/cliente';
import { fechaLegible } from '../domain/reglas-clientes';
import { PoliticaEnCorto } from './politica-en-corto';

function Seccion({ seccion }: { seccion: SeccionPolitica }) {
  return (
    <section aria-label={seccion.titulo} className="flex flex-col gap-s break-inside-avoid">
      <h2 className="text-titulo font-fuerte text-tinta">{seccion.titulo}</h2>
      <aside className="rounded-m border-l-4 border-maiz bg-aviso-fondo px-m py-s print:border-black print:bg-white">
        <p className="text-pequeno font-fuerte text-aviso print:text-black">
          En palabras de vecino
        </p>
        <p className="text-cuerpo">{seccion.enPalabrasDeVecino}</p>
      </aside>
      <div className="whitespace-pre-line text-cuerpo text-tinta-suave print:text-black">
        {seccion.texto}
      </div>
    </section>
  );
}

/** /politica-de-datos: pública, para leer en el celular o imprimir. */
export function PaginaPolitica({ fuente }: { fuente: FuentePolitica }) {
  const cargar = useCallback(() => fuente.politica(), [fuente]);
  const { estado } = useCarga(cargar);

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-l px-m py-xl print:max-w-none print:p-0">
      <p className="font-[family-name:var(--font-letrero)] text-grande font-fuerte text-selva-oscuro print:text-black">
        VECI
      </p>
      <h1 className="text-grande font-fuerte text-tinta">Cómo cuidamos tus datos</h1>
      {estado.tipo === 'cargando' && <Aviso tono="aviso">Un momento, veci…</Aviso>}
      {estado.tipo === 'error' && <Aviso tono="error">{estado.mensaje}</Aviso>}
      {estado.tipo === 'listo' && (
        <>
          <p className="text-subtitulo text-tinta-suave print:text-black">
            Política de datos, versión {estado.datos.version}. Vigente desde el{' '}
            {fechaLegible(estado.datos.publicadaEn)}.
          </p>
          <PoliticaEnCorto enCorto={estado.datos.enCorto} titulo="En corto" />
          {estado.datos.secciones.map((s) => (
            <Seccion key={s.titulo} seccion={s} />
          ))}
          <Boton
            variante="secundario"
            className="self-start print:hidden"
            onClick={() => window.print()}
          >
            Imprimir
          </Boton>
        </>
      )}
    </main>
  );
}
