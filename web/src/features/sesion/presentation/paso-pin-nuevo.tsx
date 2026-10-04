'use client';

import { useState, type FormEvent } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import { problemaConPin } from '../domain/reglas-ingreso';
import { CampoPin } from './campo-pin';

/** Tras entrar con un PIN temporal: la persona crea el suyo antes de seguir (HU-02-05). */
export function PasoPinNuevo({
  nombre,
  alCrear,
}: {
  nombre: string;
  alCrear(pin: string): Promise<void>;
}) {
  const [pin, setPin] = useState('');
  const [confirmacion, setConfirmacion] = useState('');
  const { ocupado, problema, setProblema, ejecutar } = useAccion();

  const enviar = (evento: FormEvent) => {
    evento.preventDefault();
    const aviso =
      problemaConPin(pin) ?? (pin !== confirmacion ? 'Los dos PIN no coinciden.' : null);
    if (aviso) return setProblema(aviso);
    void ejecutar(() => alCrear(pin));
  };

  return (
    <Tarjeta className="mx-auto w-full max-w-md">
      <h1 className="text-grande font-fuerte text-selva-oscuro">Hola, {nombre}</h1>
      <p className="mt-xs text-cuerpo text-tinta-suave">
        Entraste con un PIN temporal. Crea tu PIN de 6 números; solo tú lo vas a saber.
      </p>
      <form onSubmit={enviar} className="mt-l flex flex-col gap-m" noValidate>
        <CampoPin
          etiqueta="PIN nuevo"
          nuevo
          ayuda="Evita fechas, 123456 o el mismo número repetido."
          valor={pin}
          alCambiar={setPin}
        />
        <CampoPin
          etiqueta="Escríbelo otra vez"
          nuevo
          valor={confirmacion}
          alCambiar={setConfirmacion}
        />
        {problema && <Aviso tono="error">{problema}</Aviso>}
        <Boton type="submit" grande disabled={ocupado}>
          {ocupado ? 'Guardando…' : 'Guardar mi PIN'}
        </Boton>
      </form>
    </Tarjeta>
  );
}
