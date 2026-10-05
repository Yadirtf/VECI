'use client';

import { useRouter } from 'next/navigation';
import { useEffect, type ReactNode } from 'react';
import { Aviso } from '@/shared/ui';
import type { AlmacenSesion } from '../application/almacen-sesion';
import { useEstadoSesion } from '../application/use-sesion';
import { negociosDelPanel } from '../domain/reglas-ingreso';
import { FormularioIngreso } from './formulario-ingreso';
import { MarcoPanel, type MarcoPanelProps } from './marco-panel';
import { PasoPinNuevo } from './paso-pin-nuevo';
import { SelectorComercio } from './selector-comercio';

const Cargando = () => <Aviso tono="aviso">Un momento, veci…</Aviso>;

function Selector({
  almacen,
  nombre,
  espacios,
}: {
  almacen: AlmacenSesion;
  nombre: string;
  espacios: Parameters<typeof negociosDelPanel>[0];
}) {
  return (
    <SelectorComercio
      nombre={nombre}
      negocios={negociosDelPanel(espacios)}
      alElegir={(id) => almacen.elegirComercio(id)}
      alSalir={() => almacen.salir()}
    />
  );
}

/** Banda en arco detrás del formulario de entrada, con la marca pintada como letrero. */
const BandaDeEntrada = () => (
  <div
    aria-hidden="true"
    className="arco-abajo absolute inset-x-0 top-0 -z-10 h-[42vh] bg-selva-oscuro"
  >
    <p className="mx-auto max-w-5xl px-m pt-m font-[family-name:var(--font-letrero)] text-grande font-fuerte text-maiz">
      VECI
    </p>
  </div>
);

/** /entrar: ingreso, PIN nuevo si hace falta y elección del negocio; luego va al panel. */
export function PantallaEntrar({ almacen }: { almacen: AlmacenSesion }) {
  const estado = useEstadoSesion(almacen);
  const router = useRouter();
  const listo = estado.fase === 'activa' && estado.comercioId !== null;
  useEffect(() => {
    if (listo) router.replace('/');
  }, [listo, router]);

  return (
    <main className="relative isolate flex min-h-screen items-center px-m py-xl">
      <BandaDeEntrada />
      {estado.fase === 'iniciando' || listo ? (
        <div className="mx-auto">
          <Cargando />
        </div>
      ) : estado.fase === 'cambio-de-pin' ? (
        <PasoPinNuevo nombre={estado.nombre} alCrear={(pin) => almacen.crearPinNuevo(pin)} />
      ) : estado.fase === 'activa' ? (
        <Selector
          almacen={almacen}
          nombre={estado.sesion.usuario.nombre}
          espacios={estado.sesion.espacios}
        />
      ) : (
        <FormularioIngreso
          alEntrarConPin={(c, p) => almacen.entrarConPin(c, p)}
          alEntrarConContrasena={(c, p) => almacen.entrarConContrasena(c, p)}
        />
      )}
    </main>
  );
}

/** Envuelve el panel: sin sesión manda a /entrar; sin negocio pregunta cuál. */
export function GuardiaPanel(p: {
  almacen: AlmacenSesion;
  menu: MarcoPanelProps['menu'];
  children: ReactNode;
}) {
  const estado = useEstadoSesion(p.almacen);
  const router = useRouter();
  const fuera = estado.fase === 'sin-sesion' || estado.fase === 'cambio-de-pin';
  useEffect(() => {
    if (fuera) router.replace('/entrar');
  }, [fuera, router]);

  if (estado.fase !== 'activa') {
    return (
      <main className="flex min-h-screen items-center justify-center px-m">
        <Cargando />
      </main>
    );
  }
  const { sesion, comercioId } = estado;
  const negocios = negociosDelPanel(sesion.espacios);
  const negocio = negocios.find((n) => n.comercioId === comercioId);
  if (!negocio) {
    return (
      <main className="flex min-h-screen items-center px-m py-xl">
        <Selector almacen={p.almacen} nombre={sesion.usuario.nombre} espacios={sesion.espacios} />
      </main>
    );
  }
  return (
    <MarcoPanel
      negocio={negocio.nombre}
      nombre={sesion.usuario.nombre}
      menu={p.menu}
      puedeCambiarNegocio={negocios.length > 1}
      alCambiarNegocio={() => p.almacen.cambiarDeNegocio()}
      alSalir={() => void p.almacen.salir()}
    >
      {p.children}
    </MarcoPanel>
  );
}
