'use client';

import { useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import type { DatosInvitacion, Miembro, RepositorioEquipo } from '../domain/equipo';
import type { OpcionMiembro } from '../domain/reglas-equipo';

const EXITO: Partial<Record<OpcionMiembro, string>> = {
  SUSPENDER: 'quedó suspendido. Ya no puede entrar a la caja.',
  REACTIVAR: 'puede volver a entrar a la caja.',
  RETIRAR: 'ya no hace parte del equipo.',
};

export interface PinVisible {
  nombre: string;
  pin: string;
}

/** Casos de uso del equipo: invitar y gestionar a cada persona, y qué contarle a la propietaria. */
export function useAccionesEquipo(repositorio: RepositorioEquipo, recargar: () => void) {
  const { ocupado, problema, ejecutar } = useAccion();
  const [pin, setPin] = useState<PinVisible | null>(null);
  const [aviso, setAviso] = useState<string | null>(null);

  const invitar = async (datos: DatosInvitacion) => {
    const { pinTemporal } = await repositorio.invitar(datos);
    setPin(pinTemporal ? { nombre: datos.nombres, pin: pinTemporal } : null);
    setAviso(pinTemporal ? null : `${datos.nombres} ya usa VECI: entra con su PIN de siempre.`);
    recargar();
  };

  const elegir = (miembro: Miembro, opcion: OpcionMiembro) =>
    void ejecutar(async () => {
      setAviso(null);
      if (opcion === 'RESTABLECER_PIN') {
        const nuevo = await repositorio.restablecerPin(miembro.membresiaId);
        setPin({ nombre: miembro.nombre, pin: nuevo });
      } else {
        await repositorio.cambiarEstado(miembro.membresiaId, opcion);
        setAviso(`${miembro.nombre} ${EXITO[opcion]}`);
      }
      recargar();
    });

  return { ocupado, problema, pin, aviso, invitar, elegir, ocultarPin: () => setPin(null) };
}
