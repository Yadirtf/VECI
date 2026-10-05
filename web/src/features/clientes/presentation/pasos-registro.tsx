'use client';

import { useState, type FormEvent, type ReactNode } from 'react';
import { Aviso, Boton, Campo } from '@/shared/ui';
import type { DatosPersonaNueva, DocumentoPersona, TipoDocumento } from '../domain/cliente';
import { faltaEnPersonaNueva, revisarNumero } from '../domain/reglas-clientes';

export interface PasoDocumentoProps {
  tipos: readonly TipoDocumento[];
  numeroInicial: string;
  tipoInicial?: string;
  ocupado: boolean;
  alRevisar(documento: DocumentoPersona): void;
}

/** Primero el documento: así sabemos si la persona ya está en VECI. */
export function PasoDocumento(p: PasoDocumentoProps) {
  const { tipos, ocupado } = p;
  const [tipoDocumento, setTipo] = useState(p.tipoInicial ?? tipos[0]?.codigo ?? 'CC');
  const [numero, setNumero] = useState(p.numeroInicial);
  const [falta, setFalta] = useState<string | null>(null);

  const enviar = (evento: FormEvent) => {
    evento.preventDefault();
    const problema = revisarNumero(
      numero,
      tipos.find((t) => t.codigo === tipoDocumento),
    );
    setFalta(problema);
    if (!problema) p.alRevisar({ tipoDocumento, numeroDocumento: numero.trim() });
  };

  return (
    <form onSubmit={enviar} className="flex flex-col gap-m">
      <label className="flex flex-col gap-xs text-cuerpo text-tinta">
        <span className="font-medio">Tipo de documento</span>
        <select
          className="min-h-toque-boton rounded-m border-2 border-borde bg-superficie px-m"
          value={tipoDocumento}
          onChange={(e) => setTipo(e.target.value)}
        >
          {tipos.map((t) => (
            <option key={t.codigo} value={t.codigo}>
              {t.nombre}
            </option>
          ))}
        </select>
      </label>
      <Campo
        etiqueta="Número de documento"
        inputMode="numeric"
        autoComplete="off"
        value={numero}
        onChange={(e) => setNumero(e.target.value)}
      />
      {falta && <Aviso tono="aviso">{falta}</Aviso>}
      <Boton type="submit" disabled={ocupado} className="self-start">
        {ocupado ? 'Revisando…' : 'Revisar documento'}
      </Boton>
    </form>
  );
}

export interface FormularioPersonaNuevaProps {
  nombresIniciales: string;
  ocupado: boolean;
  celularEnUso: boolean;
  /** Lo que respondió la API al registrar (ya en tono VECI). */
  problema: string | null;
  alRegistrar(datos: DatosPersonaNueva, celularCompartido: boolean): void;
  /** La política en corto va entre los datos y el botón que la confirma. */
  politica: ReactNode;
}

type Persona = { nombres: string; apellidos: string; celular: string };

function CamposPersona({ persona, alCambiar }: { persona: Persona; alCambiar(p: Persona): void }) {
  const campo = (clave: keyof Persona) => ({
    value: persona[clave],
    autoComplete: 'off',
    onChange: (e: { target: { value: string } }) =>
      alCambiar({ ...persona, [clave]: e.target.value }),
  });
  return (
    <>
      <div className="grid gap-m sm:grid-cols-2">
        <Campo etiqueta="Nombres" {...campo('nombres')} />
        <Campo etiqueta="Apellidos (opcional)" {...campo('apellidos')} />
      </div>
      <Campo etiqueta="Celular" inputMode="tel" placeholder="315 777 8888" {...campo('celular')} />
    </>
  );
}

/** Datos de la persona nueva. "Sí aceptó · Registrar" confirma que se le leyó la política. */
export function FormularioPersonaNueva(p: FormularioPersonaNuevaProps) {
  const [persona, setPersona] = useState<Persona>({
    nombres: p.nombresIniciales,
    apellidos: '',
    celular: '',
  });
  const [falta, setFalta] = useState<string | null>(null);
  const datos = (): DatosPersonaNueva => ({
    nombres: persona.nombres.trim(),
    apellidos: persona.apellidos.trim() || undefined,
    celular: persona.celular.trim(),
  });

  const enviar = (evento: FormEvent) => {
    evento.preventDefault();
    const problema = faltaEnPersonaNueva(persona.nombres, persona.celular);
    setFalta(problema);
    if (!problema) p.alRegistrar(datos(), false);
  };

  return (
    <form onSubmit={enviar} className="flex flex-col gap-m">
      <CamposPersona persona={persona} alCambiar={setPersona} />
      {falta && <Aviso tono="aviso">{falta}</Aviso>}
      {p.politica}
      <Boton type="submit" disabled={p.ocupado} className="self-start">
        {p.ocupado ? 'Registrando…' : 'Sí aceptó · Registrar'}
      </Boton>
      {p.problema && <Aviso tono="error">{p.problema}</Aviso>}
      {p.celularEnUso && (
        <Boton
          variante="secundario"
          disabled={p.ocupado}
          className="self-start"
          onClick={() => p.alRegistrar(datos(), true)}
        >
          Es el celular compartido de la familia
        </Boton>
      )}
    </form>
  );
}
