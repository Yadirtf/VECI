'use client';

import { useState, type FormEvent } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Campo, Tarjeta } from '@/shared/ui';
import { problemaConCelular, problemaConPin } from '../domain/reglas-ingreso';
import { CampoPin } from './campo-pin';

export interface FormularioIngresoProps {
  alEntrarConPin(celular: string, pin: string): Promise<void>;
  alEntrarConContrasena(correo: string, contrasena: string): Promise<void>;
}

type Via = 'pin' | 'correo';

/** Entrar al panel: con celular y PIN (como en la app) o con correo y contraseña. */
export function FormularioIngreso({
  alEntrarConPin,
  alEntrarConContrasena,
}: FormularioIngresoProps) {
  const [via, setVia] = useState<Via>('pin');
  const [usuario, setUsuario] = useState('');
  const [secreto, setSecreto] = useState('');
  const { ocupado, problema, setProblema, ejecutar } = useAccion();

  const enviar = (evento: FormEvent) => {
    evento.preventDefault();
    const aviso = via === 'pin' ? (problemaConCelular(usuario) ?? problemaConPin(secreto)) : null;
    if (aviso) return setProblema(aviso);
    void ejecutar(() =>
      via === 'pin' ? alEntrarConPin(usuario, secreto) : alEntrarConContrasena(usuario, secreto),
    );
  };

  const cambiarVia = (nueva: Via) => {
    setVia(nueva);
    setUsuario('');
    setSecreto('');
    setProblema(null);
  };

  return (
    <Tarjeta className="mx-auto w-full max-w-md">
      <h1 className="text-grande font-fuerte text-selva-oscuro">¡Hola, veci!</h1>
      <p className="mt-xs text-cuerpo text-tinta-suave">Entra para ver tu negocio.</p>
      <Pestanas via={via} alCambiar={cambiarVia} />
      <form onSubmit={enviar} className="mt-l flex flex-col gap-m" noValidate>
        {via === 'pin' ? (
          <CamposPin celular={usuario} pin={secreto} setCelular={setUsuario} setPin={setSecreto} />
        ) : (
          <CamposCorreo
            correo={usuario}
            clave={secreto}
            setCorreo={setUsuario}
            setClave={setSecreto}
          />
        )}
        {problema && <Aviso tono="error">{problema}</Aviso>}
        <Boton type="submit" grande disabled={ocupado}>
          {ocupado ? 'Entrando…' : 'Entrar'}
        </Boton>
      </form>
    </Tarjeta>
  );
}

function Pestanas({ via, alCambiar }: { via: Via; alCambiar(via: Via): void }) {
  return (
    <div role="tablist" aria-label="Cómo quieres entrar" className="mt-l grid grid-cols-2 gap-s">
      <Pestana activa={via === 'pin'} onClick={() => alCambiar('pin')}>
        Celular y PIN
      </Pestana>
      <Pestana activa={via === 'correo'} onClick={() => alCambiar('correo')}>
        Correo
      </Pestana>
    </div>
  );
}

function Pestana(props: { activa: boolean; onClick(): void; children: string }) {
  return (
    <Boton
      role="tab"
      aria-selected={props.activa}
      variante={props.activa ? 'primario' : 'secundario'}
      onClick={props.onClick}
    >
      {props.children}
    </Boton>
  );
}

function CamposPin(p: {
  celular: string;
  pin: string;
  setCelular(v: string): void;
  setPin(v: string): void;
}) {
  return (
    <>
      <Campo
        etiqueta="Celular"
        inputMode="tel"
        autoComplete="tel-national"
        placeholder="310 000 0101"
        value={p.celular}
        onChange={(e) => p.setCelular(e.target.value)}
      />
      <CampoPin
        etiqueta="PIN"
        ayuda="Los 6 números con los que entras a VECI."
        valor={p.pin}
        alCambiar={p.setPin}
      />
    </>
  );
}

function CamposCorreo(p: {
  correo: string;
  clave: string;
  setCorreo(v: string): void;
  setClave(v: string): void;
}) {
  return (
    <>
      <Campo
        etiqueta="Correo"
        type="email"
        autoComplete="username"
        value={p.correo}
        onChange={(e) => p.setCorreo(e.target.value)}
      />
      <Campo
        etiqueta="Contraseña"
        type="password"
        autoComplete="current-password"
        ayuda="La defines en Mi cuenta después de entrar con tu PIN."
        value={p.clave}
        onChange={(e) => p.setClave(e.target.value)}
      />
    </>
  );
}
