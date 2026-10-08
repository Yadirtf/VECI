'use client';

import { Aviso, Boton, Saldo } from '@/shared/ui';
import { useCuenta } from '../application/use-cuenta';
import { cantidad, diaLegible, TEXTO_ESTADO } from '../domain/reglas-tiqueteras';
import type { RepositorioCuentas, Tiquetera } from '../domain/tiquetera';
import { FormularioCorreccion } from './correccion';
import { FormularioVenta } from './formulario-venta';
import { Historia } from './historia';

type Cuenta = ReturnType<typeof useCuenta>;

export interface CuentaDelClienteProps {
  repositorio: RepositorioCuentas;
  clienteId: string;
  nuevoId(): string;
}

/** Un cartón de la pila: la que vence primero va arriba y se gasta primero. */
function Carton({ t, c }: { t: Tiquetera; c: Cuenta }) {
  return (
    <li
      className={`flex flex-wrap items-center justify-between gap-m rounded-m border-2 border-borde bg-crema p-m ${t.vigente ? '' : 'opacity-70'}`}
    >
      <div>
        <p className="text-cuerpo font-fuerte">
          {t.turno === 1 ? 'Se gasta primero · ' : ''}
          {t.nombre}
        </p>
        <p className="text-pequeno text-tinta-suave">
          {cantidad(t.saldo, t.unidad)} de {t.compradas} · {TEXTO_ESTADO[t.estado]}
          {t.estado === 'ACTIVE' && !t.vigente ? ' (venció)' : ''} · último día{' '}
          {diaLegible(t.ultimoDia)}
        </p>
      </div>
      <Boton
        variante="secundario"
        disabled={c.ocupado}
        onClick={() => c.abrir({ tipo: 'ajustar', tiquetera: t })}
      >
        Ajustar
      </Boton>
    </li>
  );
}

function Accion({ c }: { c: Cuenta }) {
  const a = c.accion;
  if (a.tipo === 'vender' && c.catalogo) {
    return (
      <FormularioVenta
        tipos={c.catalogo.tipos}
        medios={c.catalogo.medios}
        ocupado={c.ocupado}
        problema={c.problema}
        alVender={c.vender}
        alCancelar={c.cancelar}
      />
    );
  }
  if (a.tipo === 'ajustar' && c.motivos) {
    return (
      <FormularioCorreccion
        titulo={`Ajustar «${a.tiquetera.nombre}» (le quedan ${a.tiquetera.saldo})`}
        motivos={c.motivos}
        conUnidades
        textoBoton="Guardar ajuste"
        ocupado={c.ocupado}
        problema={c.problema}
        alEnviar={(correccion, unidades) => c.ajustar(a.tiquetera, unidades, correccion)}
        alCancelar={c.cancelar}
      />
    );
  }
  return null;
}

/** Saldo, tiqueteras, venta y ajustes del cliente en este negocio (HU-05-02, -03, -05). */
export function CuentaDelCliente({ repositorio, clienteId, nuevoId }: CuentaDelClienteProps) {
  const c = useCuenta(repositorio, clienteId, nuevoId);
  if (c.estado.tipo === 'error') return <Aviso tono="error">{c.estado.mensaje}</Aviso>;
  if (!c.cuenta) return <Aviso tono="aviso">Un momento, veci, ya traemos su saldo…</Aviso>;
  const { saldos, tiqueteras, movimientos } = c.cuenta;
  return (
    <section aria-label="Tiqueteras del cliente" className="flex flex-col gap-m">
      <div className="flex flex-wrap items-center justify-between gap-m">
        <h3 className="text-subtitulo font-fuerte">Tiqueteras</h3>
        {c.accion.tipo === 'nada' && (
          <Boton disabled={c.ocupado} onClick={() => c.abrir({ tipo: 'vender' })}>
            Vender tiquetera
          </Boton>
        )}
      </div>
      {c.aviso && <Aviso tono="exito">{c.aviso}</Aviso>}
      {saldos.length === 0 ? (
        <p className="text-cuerpo text-tinta-suave">No tiene saldo vigente.</p>
      ) : (
        <div className="flex flex-wrap gap-m">
          {saldos.map((s) => (
            <div key={s.unidad.codigo} className="flex flex-col gap-xs">
              <Saldo
                unidades={s.disponibles}
                singular={s.unidad.singular}
                plural={s.unidad.plural}
              />
              <span className="text-pequeno text-tinta-suave">
                En {s.tiqueteras} {s.tiqueteras === 1 ? 'tiquetera' : 'tiqueteras'} · la primera
                sirve hasta el {diaLegible(s.ultimoDia)}
              </span>
            </div>
          ))}
        </div>
      )}
      <Accion c={c} />
      {c.accion.tipo === 'nada' && c.problema && <Aviso tono="error">{c.problema}</Aviso>}
      {tiqueteras.length > 0 && (
        <ul className="flex flex-col gap-s">
          {tiqueteras.map((t) => (
            <Carton key={t.tiqueteraId} t={t} c={c} />
          ))}
        </ul>
      )}
      <Historia movimientos={movimientos} />
    </section>
  );
}
