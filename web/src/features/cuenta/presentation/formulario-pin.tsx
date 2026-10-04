'use client';

import { useState, type FormEvent } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Campo, Tarjeta } from '@/shared/ui';
import { problemaConPinNuevo, type RepositorioCuenta } from '../domain/cuenta';

const soloNumeros = (v: string) => v.replace(/\D/g, '').slice(0, 6);
const VACIO = { actual: '', nuevo: '', repetido: '' };

/** Cambiar mi PIN (HU-02-03). */
export function FormularioPin({ repositorio }: { repositorio: RepositorioCuenta }) {
  const [pin, setPin] = useState(VACIO);
  const [listo, setListo] = useState(false);
  const { ocupado, problema, setProblema, ejecutar } = useAccion();
  const campo = (clave: keyof typeof VACIO) => ({
    type: 'password',
    inputMode: 'numeric' as const,
    value: pin[clave],
    onChange: (e: { target: { value: string } }) =>
      setPin({ ...pin, [clave]: soloNumeros(e.target.value) }),
  });

  const enviar = async (evento: FormEvent) => {
    evento.preventDefault();
    setListo(false);
    const aviso = problemaConPinNuevo(pin.actual, pin.nuevo, pin.repetido);
    if (aviso) return setProblema(aviso);
    if (await ejecutar(() => repositorio.cambiarPin(pin.actual, pin.nuevo))) {
      setPin(VACIO);
      setListo(true);
    }
  };

  return (
    <Tarjeta>
      <h2 className="text-titulo font-fuerte text-tinta">Cambiar mi PIN</h2>
      <form onSubmit={enviar} className="mt-m flex flex-col gap-m" noValidate>
        <Campo etiqueta="PIN actual" autoComplete="current-password" {...campo('actual')} />
        <Campo etiqueta="PIN nuevo" autoComplete="new-password" {...campo('nuevo')} />
        <Campo
          etiqueta="Escribe el nuevo otra vez"
          autoComplete="new-password"
          {...campo('repetido')}
        />
        {problema && <Aviso tono="error">{problema}</Aviso>}
        {listo && <Aviso tono="exito">¡Listo! Desde ahora entras con tu PIN nuevo.</Aviso>}
        <Boton type="submit" disabled={ocupado}>
          {ocupado ? 'Guardando…' : 'Guardar PIN'}
        </Boton>
      </form>
    </Tarjeta>
  );
}
