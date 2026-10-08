'use client';

import type { ReactNode } from 'react';
import { Aviso, Boton, Campo, PinParaDictar, Tarjeta } from '@/shared/ui';
import { useLibreta } from '../application/use-libreta';
import type { RepositorioClientes } from '../domain/cliente';
import { resumenLibreta } from '../domain/reglas-clientes';
import { FichaCliente } from './ficha-cliente';
import { Filtros, Renglones } from './libreta';
import { RegistroAsistido } from './registro-asistido';

type Libreta = ReturnType<typeof useLibreta>;

const INDICACION_PIN =
  'Sirve 7 días. Con su celular y este PIN activa su app. Por seguridad no lo volvemos a mostrar.';

function SinRenglones({ l }: { l: Libreta }) {
  const texto = l.texto.trim();
  if (l.todos.length === 0) {
    return (
      <p className="p-m text-cuerpo text-tinta-suave">
        Aún no tienes clientes. Se anotan con su QR en la caja o aquí con «Registrar cliente».
      </p>
    );
  }
  if (!texto) {
    return <p className="p-m text-cuerpo text-tinta-suave">Todos tus clientes ya usan la app.</p>;
  }
  if (l.servidor.buscando) return <p className="p-m text-cuerpo text-tinta-suave">Buscando…</p>;
  return (
    <div className="flex flex-col items-start gap-s p-m">
      <p className="text-cuerpo">No encontramos a «{texto}».</p>
      <Boton variante="secundario" onClick={l.registrarNuevo}>
        Registrar a «{texto}»
      </Boton>
    </div>
  );
}

function ColumnaLibreta({ l }: { l: Libreta }) {
  if (l.estado.tipo === 'cargando') {
    return <Aviso tono="aviso">Un momento, veci, ya traemos tus clientes…</Aviso>;
  }
  if (l.estado.tipo === 'error') return <Aviso tono="error">{l.estado.mensaje}</Aviso>;
  const elegido = l.ventanilla.tipo === 'ficha' ? l.ventanilla.clienteId : null;
  return (
    <Tarjeta aria-label="Libreta de clientes" className="flex flex-col gap-s">
      {l.visibles.length > 0 ? (
        <Renglones clientes={l.visibles} elegido={elegido} alElegir={l.elegir} />
      ) : (
        <SinRenglones l={l} />
      )}
      {l.servidor.problema && <Aviso tono="error">{l.servidor.problema}</Aviso>}
    </Tarjeta>
  );
}

/** Lo que otra funcionalidad pone bajo la ficha: el saldo de tiqueteras (EP-05). */
export type ExtraDeFicha = (clienteId: string) => ReactNode;

interface VentanillaProps {
  l: Libreta;
  repositorio: RepositorioClientes;
  cuenta?: ExtraDeFicha;
}

function Ventanilla({ l, repositorio, cuenta }: VentanillaProps) {
  const v = l.ventanilla;
  return (
    <div className="flex flex-col gap-m">
      {l.pin && (
        <PinParaDictar
          titulo="PIN de bienvenida"
          nombre={l.pin.nombre}
          pin={l.pin.pin}
          indicacion={INDICACION_PIN}
          alCerrar={l.ocultarPin}
        />
      )}
      {l.aviso && <Aviso tono="exito">{l.aviso}</Aviso>}
      {v.tipo === 'ficha' && (
        <FichaCliente
          key={v.clienteId}
          repositorio={repositorio}
          clienteId={v.clienteId}
          alDarPin={l.mostrarPin}
        />
      )}
      {v.tipo === 'ficha' && cuenta && (
        <Tarjeta aria-label="Saldo de tiqueteras">{cuenta(v.clienteId)}</Tarjeta>
      )}
      {v.tipo === 'registro' && (
        <RegistroAsistido
          key={v.desde}
          repositorio={repositorio}
          desde={v.desde}
          alRegistrar={l.registrado}
          alVerFicha={l.elegir}
        />
      )}
      {v.tipo === 'vacia' && (
        <Tarjeta perforado aria-label="Ventanilla">
          <p className="text-cuerpo">Elige un cliente para ver su ficha, o registra uno nuevo.</p>
        </Tarjeta>
      )}
    </div>
  );
}

/** Tus clientes: la libreta a la izquierda y la ventanilla con la ficha o el registro. */
export function PantallaClientes({
  repositorio,
  cuenta,
}: {
  repositorio: RepositorioClientes;
  cuenta?: ExtraDeFicha;
}) {
  const l = useLibreta(repositorio);
  return (
    <div className="flex flex-col gap-l">
      <div className="flex flex-wrap items-center justify-between gap-m">
        <p className="text-subtitulo text-tinta-suave">
          {l.estado.tipo === 'listo' ? resumenLibreta(l.todos) : 'Tu libreta de clientes'}
        </p>
        <Boton onClick={l.registrarNuevo}>Registrar cliente</Boton>
      </div>
      <Campo
        etiqueta="Buscar por nombre, celular o documento"
        type="search"
        autoComplete="off"
        value={l.texto}
        onChange={(e) => l.setTexto(e.target.value)}
      />
      <Filtros filtro={l.filtro} alCambiar={l.setFiltro} />
      <div className="grid items-start gap-l lg:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)]">
        <ColumnaLibreta l={l} />
        <Ventanilla l={l} repositorio={repositorio} cuenta={cuenta} />
      </div>
    </div>
  );
}
