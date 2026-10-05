'use client';

import { useCallback } from 'react';
import { useCarga } from '@/shared/lib/use-carga';
import { Aviso, PinParaDictar } from '@/shared/ui';
import { useAccionesEquipo } from '../application/use-acciones-equipo';
import type { RepositorioEquipo } from '../domain/equipo';
import { ordenarEquipo } from '../domain/reglas-equipo';
import { FormularioInvitacion } from './formulario-invitacion';
import { TarjetaMiembro } from './tarjeta-miembro';

/** Equipo del negocio: invitar cajeros, suspender, reactivar, retirar y dar PIN nuevo. */
export function PantallaEquipo({ repositorio }: { repositorio: RepositorioEquipo }) {
  const listar = useCallback(() => repositorio.listar(), [repositorio]);
  const { estado, recargar } = useCarga(listar);
  const a = useAccionesEquipo(repositorio, recargar);

  return (
    <div className="flex flex-col gap-l">
      {a.pin && <PinParaDictar nombre={a.pin.nombre} pin={a.pin.pin} alCerrar={a.ocultarPin} />}
      {a.aviso && <Aviso tono="exito">{a.aviso}</Aviso>}
      {a.problema && <Aviso tono="error">{a.problema}</Aviso>}
      <FormularioInvitacion alInvitar={a.invitar} />
      {estado.tipo === 'cargando' && (
        <Aviso tono="aviso">Un momento, veci, ya traemos tu equipo…</Aviso>
      )}
      {estado.tipo === 'error' && <Aviso tono="error">{estado.mensaje}</Aviso>}
      {estado.tipo === 'listo' && (
        <div className="grid gap-m sm:grid-cols-2">
          {ordenarEquipo(estado.datos).map((m) => (
            <TarjetaMiembro
              key={m.membresiaId}
              miembro={m}
              ocupado={a.ocupado}
              alElegir={(opcion) => a.elegir(m, opcion)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
