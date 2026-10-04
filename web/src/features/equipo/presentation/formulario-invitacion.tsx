'use client';

import { useState, type FormEvent } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Campo, Tarjeta } from '@/shared/ui';
import type { DatosInvitacion } from '../domain/equipo';

// Documentos de una persona adulta (catálogo core.document_types).
const DOCUMENTOS = [
  ['CC', 'Cédula de ciudadanía'],
  ['CE', 'Cédula de extranjería'],
  ['PPT', 'Permiso por protección temporal'],
  ['PASSPORT', 'Pasaporte'],
] as const;

const VACIO: DatosInvitacion = {
  celular: '',
  nombres: '',
  apellidos: '',
  tipoDocumento: 'CC',
  numeroDocumento: '',
};

/** Invitar un cajero con su celular y documento (HU-02-04). */
export interface FormularioInvitacionProps {
  alInvitar(d: DatosInvitacion): Promise<void>;
}

export function FormularioInvitacion({ alInvitar }: FormularioInvitacionProps) {
  const [datos, setDatos] = useState(VACIO);
  const { ocupado, problema, ejecutar } = useAccion();
  const campo = (clave: keyof DatosInvitacion) => ({
    value: datos[clave] ?? '',
    onChange: (e: { target: { value: string } }) => setDatos({ ...datos, [clave]: e.target.value }),
  });

  const enviar = async (evento: FormEvent) => {
    evento.preventDefault();
    const apellidos = datos.apellidos?.trim() || undefined;
    if (await ejecutar(() => alInvitar({ ...datos, apellidos }))) setDatos(VACIO);
  };

  return (
    <Tarjeta>
      <h2 className="text-titulo font-fuerte text-tinta">Invitar cajero</h2>
      <form onSubmit={enviar} className="mt-m grid gap-m sm:grid-cols-2">
        <Campo etiqueta="Nombres" autoComplete="off" required {...campo('nombres')} />
        <Campo etiqueta="Apellidos" autoComplete="off" {...campo('apellidos')} />
        <Campo
          etiqueta="Celular"
          inputMode="tel"
          placeholder="312 456 7890"
          required
          {...campo('celular')}
        />
        <SelectorDocumento {...campo('tipoDocumento')} />
        <Campo
          etiqueta="Número de documento"
          inputMode="numeric"
          required
          {...campo('numeroDocumento')}
        />
        <div className="flex items-end">
          <Boton type="submit" disabled={ocupado} className="w-full">
            {ocupado ? 'Invitando…' : 'Invitar'}
          </Boton>
        </div>
        <div className="sm:col-span-2">{problema && <Aviso tono="error">{problema}</Aviso>}</div>
      </form>
    </Tarjeta>
  );
}

function SelectorDocumento(props: {
  value: string;
  onChange(e: { target: { value: string } }): void;
}) {
  return (
    <label className="flex flex-col gap-xs text-cuerpo text-tinta">
      <span className="font-medio">Tipo de documento</span>
      <select
        className="min-h-toque-boton rounded-m border-2 border-borde bg-superficie px-m"
        {...props}
      >
        {DOCUMENTOS.map(([codigo, nombre]) => (
          <option key={codigo} value={codigo}>
            {nombre}
          </option>
        ))}
      </select>
    </label>
  );
}
