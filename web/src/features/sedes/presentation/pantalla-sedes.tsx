'use client';

import { useState } from 'react';
import { Aviso, Boton, Campo } from '@/shared/ui';
import { useCaserio } from '../application/use-caserio';
import { puedeAgregarSede } from '../domain/reglas-sedes';
import type { RepositorioSedes, Sede } from '../domain/sede';
import { Caserio } from './caserio';
import { QuienTrabajaDonde } from './quien-trabaja-donde';

type Acciones = ReturnType<typeof useCaserio>;

function NuevaSede({ c, alTerminar }: { c: Acciones; alTerminar(): void }) {
  const [nombre, setNombre] = useState('');
  const [direccion, setDireccion] = useState('');
  const crear = () =>
    void c.crear(nombre.trim(), direccion.trim() || null).then((ok) => ok && alTerminar());
  return (
    <form className="flex flex-col gap-m" onSubmit={(e) => (e.preventDefault(), crear())}>
      <Campo
        etiqueta="¿Cómo le dicen a la nueva sede?"
        value={nombre}
        maxLength={60}
        placeholder="Sede del parque"
        onChange={(e) => setNombre(e.target.value)}
      />
      <Campo
        etiqueta="Dirección (opcional)"
        value={direccion}
        onChange={(e) => setDireccion(e.target.value)}
      />
      <Boton
        type="submit"
        disabled={c.accion.ocupado || nombre.trim().length < 2}
        className="self-start"
      >
        Armar la casa
      </Boton>
    </form>
  );
}

function DetalleSede({ sede, c }: { sede: Sede; c: Acciones }) {
  return (
    <div className="flex flex-col gap-s">
      <h2 className="text-titulo font-fuerte text-arcilla">{sede.nombre}</h2>
      <p className="text-cuerpo text-tinta-suave">
        {[sede.direccion, sede.municipio].filter(Boolean).join(', ') || 'Sin dirección todavía'}
      </p>
      {sede.principal ? (
        <p className="text-cuerpo">Es la casa principal: siempre está abierta.</p>
      ) : (
        <Boton
          variante="secundario"
          disabled={c.accion.ocupado}
          className="self-start"
          onClick={() => void c.cambiarActiva(sede)}
        >
          {sede.activa ? 'Cerrar esta sede' : 'Volver a abrir esta sede'}
        </Boton>
      )}
    </div>
  );
}

/** Sedes del negocio y quién trabaja en cada una (HU-03-03). */
export function PantallaSedes({ repositorio }: { repositorio: RepositorioSedes }) {
  const c = useCaserio(repositorio);
  const [elegida, setElegida] = useState<string | null>(null);
  if (c.estado.tipo === 'cargando')
    return <Aviso tono="aviso">Un momento, veci, ya traemos tus sedes…</Aviso>;
  if (c.estado.tipo === 'error') return <Aviso tono="error">{c.estado.mensaje}</Aviso>;
  const mapa = c.estado.datos;
  const sede = mapa.sedes.find((s) => s.id === elegida);
  return (
    <div className="flex flex-col gap-l">
      <div className="flex justify-center rounded-l bg-superficie p-m">
        <Caserio mapa={mapa} elegida={elegida} alElegir={setElegida} />
      </div>
      {c.accion.problema && <Aviso tono="error">{c.accion.problema}</Aviso>}
      {sede && <DetalleSede sede={sede} c={c} />}
      {elegida === 'NUEVA' &&
        (puedeAgregarSede(mapa.cupo) ? (
          <NuevaSede c={c} alTerminar={() => setElegida(null)} />
        ) : (
          <Aviso tono="aviso">
            Varias sedes vienen con el plan Pro. Escríbenos y te ayudamos a pasarte.
          </Aviso>
        ))}
      <h2 className="text-titulo font-fuerte text-tinta">Quién trabaja dónde</h2>
      <QuienTrabajaDonde
        cajeros={mapa.cajeros}
        sedes={mapa.sedes}
        ocupado={c.accion.ocupado}
        alAlternar={(cj, id) => void c.alternar(cj, id)}
      />
    </div>
  );
}
