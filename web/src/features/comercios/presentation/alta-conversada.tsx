'use client';

import { useState } from 'react';
import { Aviso, Boton } from '@/shared/ui';
import { useCarga } from '@/shared/lib/use-carga';
import type { useAlta } from '../application/use-alta';
import { PASOS, type PasoAlta } from '../domain/alta';
import type { Municipio, TipoDeNegocio } from '../domain/comercio';
import { Letrero } from './letrero';
import { CaminoDePiedras } from './piedras';
import {
  PreguntaContacto,
  PreguntaDocumento,
  PreguntaLugar,
  PreguntaNombre,
  PreguntaTipo,
} from './preguntas-alta';

const NOMBRES: Record<PasoAlta, string> = {
  NOMBRE: 'Nombre',
  TIPO: 'Qué vende',
  DOCUMENTO: 'Documento',
  CONTACTO: 'Contacto',
  LUGAR: 'Dónde queda',
  LETRERO: 'Letrero',
};

export interface CatalogosAlta {
  tipos: TipoDeNegocio[];
  municipios: Municipio[];
}

interface Props {
  alta: ReturnType<typeof useAlta>;
  cargarCatalogos(): Promise<CatalogosAlta>;
  alRegistrar(comercioId: string): Promise<void>;
}

function PasoActual({ alta, catalogos }: { alta: Props['alta']; catalogos: CatalogosAlta }) {
  const props = { borrador: alta.borrador, cambiar: alta.cambiar };
  const tipo = catalogos.tipos.find((t) => t.codigo === alta.borrador.tipoNegocio);
  switch (alta.paso) {
    case 'NOMBRE':
      return <PreguntaNombre {...props} />;
    case 'TIPO':
      return <PreguntaTipo {...props} tipos={catalogos.tipos} />;
    case 'DOCUMENTO':
      return <PreguntaDocumento {...props} />;
    case 'CONTACTO':
      return <PreguntaContacto {...props} />;
    case 'LUGAR':
      return <PreguntaLugar {...props} municipios={catalogos.municipios} />;
    default:
      return <Letrero borrador={alta.borrador} tipo={tipo} />;
  }
}

function Botonera(p: { atras: (() => void) | null; ultimo: boolean; ocupado: boolean }) {
  const texto = !p.ultimo
    ? 'Seguir'
    : p.ocupado
      ? 'Colgando el letrero…'
      : 'Abrir mi negocio en VECI';
  return (
    <div className="flex flex-wrap-reverse items-center justify-between gap-m">
      {p.atras ? (
        <button
          type="button"
          onClick={p.atras}
          className="min-h-toque-boton px-m text-subtitulo text-selva-oscuro underline"
        >
          Atrás
        </button>
      ) : (
        <span />
      )}
      <Boton type="submit" grande disabled={p.ocupado}>
        {texto}
      </Boton>
    </div>
  );
}

/**
 * Registrar un negocio como una conversación: una pregunta por pantalla, el avance
 * como piedras para cruzar la quebrada y, al final, el letrero del negocio (HU-03-01).
 */
export function AltaConversada({ alta, cargarCatalogos, alRegistrar }: Props) {
  const { estado } = useCarga(cargarCatalogos);
  const [abriendo, setAbriendo] = useState(false);
  const ultimo = alta.indice === PASOS.length - 1;
  const piedras = PASOS.map((p, i) => ({
    etiqueta: NOMBRES[p],
    lista: i < alta.indice,
    actual: i === alta.indice,
  }));

  const terminar = async () => {
    const comercioId = await alta.registrar();
    if (!comercioId) return;
    setAbriendo(true);
    await alRegistrar(comercioId);
  };

  if (estado.tipo === 'cargando')
    return <p className="text-cuerpo text-tinta-suave">Un momento, veci…</p>;
  if (estado.tipo === 'error') return <Aviso tono="error">{estado.mensaje}</Aviso>;

  return (
    <form
      className="mx-auto flex w-full max-w-[36rem] flex-col gap-l"
      onSubmit={(e) => {
        e.preventDefault();
        if (ultimo) void terminar();
        else alta.seguir();
      }}
    >
      <CaminoDePiedras
        piedras={piedras}
        titulo={`Paso ${alta.indice + 1} de ${PASOS.length}: ${NOMBRES[alta.paso]}`}
      />
      <div key={alta.paso}>
        <PasoActual alta={alta} catalogos={estado.datos} />
      </div>
      {alta.problema && <Aviso tono="aviso">{alta.problema}</Aviso>}
      <Botonera
        atras={alta.indice > 0 ? alta.volver : null}
        ultimo={ultimo}
        ocupado={alta.ocupado || abriendo}
      />
    </form>
  );
}
