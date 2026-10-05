'use client';

import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import type { PinVisible } from '../application/use-libreta';
import { useFicha } from '../application/use-ficha';
import type { FichaCliente as Ficha, RepositorioClientes } from '../domain/cliente';
import { celularLegible, fechaLegible, TEXTO_CANAL, TEXTO_CUENTA } from '../domain/reglas-clientes';

export interface FichaClienteProps {
  repositorio: RepositorioClientes;
  clienteId: string;
  alDarPin(pin: PinVisible): void;
}

function Dato({ etiqueta, valor }: { etiqueta: string; valor: string }) {
  return (
    <div className="flex flex-col">
      <dt className="text-pequeno text-tinta-suave">{etiqueta}</dt>
      <dd className="text-cuerpo font-medio text-tinta">{valor}</dd>
    </div>
  );
}

/** Explica quién ve qué: el dueño ve todo, la caja lo ve tapado. */
function Leyenda({ completos }: { completos: boolean }) {
  return (
    <p className="text-pequeno text-tinta-suave">
      {completos
        ? 'Ves el documento y el celular completos porque eres el dueño. En la caja tu equipo los ve tapados, así: ****5678.'
        : 'El documento y el celular se ven tapados para cuidar a tus clientes.'}
    </p>
  );
}

function Datos({ ficha }: { ficha: Ficha }) {
  return (
    <dl className="grid gap-m sm:grid-cols-2">
      <Dato etiqueta="Documento" valor={`${ficha.tipoDocumento} ${ficha.documento}`} />
      <Dato etiqueta="Celular" valor={celularLegible(ficha.celular)} />
      <Dato etiqueta="App de VECI" valor={TEXTO_CUENTA[ficha.cuenta]} />
      <Dato etiqueta="Cliente desde" valor={fechaLegible(ficha.afiliadoEn)} />
      <Dato etiqueta="Cómo llegó" valor={TEXTO_CANAL[ficha.canal]} />
    </dl>
  );
}

/** Ficha del cliente en la ventanilla; si su app espera el PIN, se lo damos aquí. */
export function FichaCliente({ repositorio, clienteId, alDarPin }: FichaClienteProps) {
  const f = useFicha(repositorio, clienteId, alDarPin);
  if (f.estado.tipo === 'cargando') return <Aviso tono="aviso">Un momento, veci…</Aviso>;
  if (f.estado.tipo === 'error') return <Aviso tono="error">{f.estado.mensaje}</Aviso>;
  const ficha = f.estado.datos;
  return (
    <Tarjeta aria-label={`Ficha de ${ficha.nombre}`} className="flex flex-col gap-m">
      <h2 className="text-titulo font-fuerte text-tinta">{ficha.nombre}</h2>
      <Datos ficha={ficha} />
      <Leyenda completos={ficha.datosCompletos} />
      {ficha.cuenta === 'PENDIENTE' && (
        <div className="flex flex-col gap-s">
          <p className="text-cuerpo">
            Aún no activa su app. Con un PIN de bienvenida entra con su celular.
          </p>
          <Boton
            variante="secundario"
            className="self-start"
            disabled={f.ocupado}
            onClick={() => f.darPin(ficha)}
          >
            {f.ocupado ? 'Un momento…' : 'Dar PIN de bienvenida'}
          </Boton>
        </div>
      )}
      {f.problema && <Aviso tono="error">{f.problema}</Aviso>}
    </Tarjeta>
  );
}
