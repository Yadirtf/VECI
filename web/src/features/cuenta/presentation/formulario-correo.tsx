'use client';

import { useState, type FormEvent } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Campo, Tarjeta } from '@/shared/ui';
import { problemaConContrasena, type RepositorioCuenta } from '../domain/cuenta';

const EXPLICACION = 'Para el computador del negocio. En el celular sigues entrando con tu PIN.';

/** Correo y contraseña para entrar al panel desde el computador (HU-02-02). */
export function FormularioCorreo({ repositorio }: { repositorio: RepositorioCuenta }) {
  const [correo, setCorreo] = useState('');
  const [contrasena, setContrasena] = useState('');
  const [pin, setPin] = useState('');
  const [guardado, setGuardado] = useState<string | null>(null);
  const { ocupado, problema, setProblema, ejecutar } = useAccion();

  const enviar = async (evento: FormEvent) => {
    evento.preventDefault();
    setGuardado(null);
    const aviso = problemaConContrasena(correo, contrasena);
    if (aviso) return setProblema(aviso);
    await ejecutar(async () => {
      setGuardado(await repositorio.definirCorreo(correo, contrasena, pin));
      setContrasena('');
      setPin('');
    });
  };

  return (
    <Tarjeta>
      <h2 className="text-titulo font-fuerte text-tinta">Entrar con correo</h2>
      <p className="mt-xs text-cuerpo text-tinta-suave">{EXPLICACION}</p>
      <form onSubmit={enviar} className="mt-m flex flex-col gap-m" noValidate>
        <Campo
          etiqueta="Correo"
          type="email"
          autoComplete="email"
          value={correo}
          onChange={(e) => setCorreo(e.target.value)}
        />
        <Campo
          etiqueta="Contraseña"
          type="password"
          autoComplete="new-password"
          ayuda="Mínimo 8 caracteres."
          value={contrasena}
          onChange={(e) => setContrasena(e.target.value)}
        />
        <CampoConfirmarPin valor={pin} alCambiar={setPin} />
        {problema && <Aviso tono="error">{problema}</Aviso>}
        {guardado && <Aviso tono="exito">¡Listo! Ya puedes entrar al panel con {guardado}.</Aviso>}
        <Boton type="submit" disabled={ocupado}>
          {ocupado ? 'Guardando…' : 'Guardar correo y contraseña'}
        </Boton>
      </form>
    </Tarjeta>
  );
}

function CampoConfirmarPin({ valor, alCambiar }: { valor: string; alCambiar(v: string): void }) {
  return (
    <Campo
      etiqueta="Tu PIN, para confirmar que eres tú"
      type="password"
      inputMode="numeric"
      value={valor}
      onChange={(e) => alCambiar(e.target.value.replace(/\D/g, '').slice(0, 6))}
    />
  );
}
