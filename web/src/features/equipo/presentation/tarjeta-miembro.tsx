'use client';

import { useState } from 'react';
import { Boton, Tarjeta } from '@/shared/ui';
import type { Miembro } from '../domain/equipo';
import {
  celularLegible,
  opcionesPara,
  type OpcionMiembro,
  TEXTO_ESTADO,
  TEXTO_OPCION,
  textoRol,
} from '../domain/reglas-equipo';

const PIDEN_CONFIRMAR: readonly OpcionMiembro[] = ['SUSPENDER', 'RETIRAR'];

export interface TarjetaMiembroProps {
  miembro: Miembro;
  ocupado: boolean;
  alElegir(opcion: OpcionMiembro): void;
}

/** Una persona del equipo con lo que se puede hacer con ella. */
export function TarjetaMiembro({ miembro, ocupado, alElegir }: TarjetaMiembroProps) {
  const [confirmando, setConfirmando] = useState<OpcionMiembro | null>(null);
  const elegir = (opcion: OpcionMiembro) => {
    if (PIDEN_CONFIRMAR.includes(opcion) && confirmando !== opcion) return setConfirmando(opcion);
    setConfirmando(null);
    alElegir(opcion);
  };

  return (
    <Tarjeta aria-label={miembro.nombre} className="flex flex-col gap-s">
      <div className="flex flex-wrap items-baseline justify-between gap-s">
        <h3 className="text-titulo font-fuerte text-tinta">{miembro.nombre}</h3>
        <span className="text-cuerpo text-tinta-suave">{textoRol(miembro)}</span>
      </div>
      <p className="text-cuerpo">{celularLegible(miembro.celular)}</p>
      <p className="text-cuerpo font-medio">{TEXTO_ESTADO[miembro.estado]}</p>
      {confirmando && (
        <p role="alert" className="text-cuerpo text-error">
          ¿Seguro? Toca otra vez “{TEXTO_OPCION[confirmando]}” para confirmar.
        </p>
      )}
      <div className="flex flex-wrap gap-s">
        {opcionesPara(miembro).map((opcion) => (
          <Boton
            key={opcion}
            variante={PIDEN_CONFIRMAR.includes(opcion) ? 'peligro' : 'secundario'}
            disabled={ocupado}
            onClick={() => elegir(opcion)}
          >
            {TEXTO_OPCION[opcion]}
          </Boton>
        ))}
      </div>
    </Tarjeta>
  );
}
