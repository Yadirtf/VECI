'use client';

import { useCallback, useState } from 'react';
import { Aviso, Boton, Campo } from '@/shared/ui';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import type { Perfil, RepositorioComercios } from '../domain/comercio';
import { nitLegible } from '../domain/nit';
import { SelloNegocio } from './sello';

interface Datos {
  nombre: string;
  celular: string;
  correo: string;
  logoUrl: string;
}

const CAMPOS: { clave: keyof Datos; etiqueta: string; tipo?: string }[] = [
  { clave: 'nombre', etiqueta: 'Nombre del negocio' },
  { clave: 'celular', etiqueta: 'Celular', tipo: 'tel' },
  { clave: 'correo', etiqueta: 'Correo (si tienes)', tipo: 'email' },
  { clave: 'logoUrl', etiqueta: 'Enlace del logo (https)', tipo: 'url' },
];

const aDatos = (p: Perfil): Datos => ({
  nombre: p.nombre,
  celular: p.celular ?? '',
  correo: p.correo ?? '',
  logoUrl: p.logoUrl ?? '',
});

function SelloYDocumento({ perfil, datos }: { perfil: Perfil; datos: Datos }) {
  const { tipo, numero } = perfil.documento;
  const logo = /^https:\/\//.test(datos.logoUrl) ? datos.logoUrl : null;
  return (
    <div className="flex flex-col items-center gap-s md:pt-l">
      <SelloNegocio nombre={datos.nombre} logoUrl={logo} tamano={140} />
      <p className="text-cuerpo text-tinta-suave">
        {tipo === 'NIT' ? `NIT ${nitLegible(numero)}` : `Cédula ${numero}`}
      </p>
    </div>
  );
}

function Formulario({
  perfil,
  repositorio,
}: {
  perfil: Perfil;
  repositorio: RepositorioComercios;
}) {
  const [datos, setDatos] = useState<Datos>(() => aDatos(perfil));
  const [guardado, setGuardado] = useState(false);
  const { ocupado, problema, ejecutar } = useAccion();
  const guardar = () =>
    ejecutar(async () => {
      setGuardado(false);
      const correo = datos.correo.trim() || null;
      await repositorio.editar({ ...datos, correo, logoUrl: datos.logoUrl.trim() || null });
      setGuardado(true);
    });
  return (
    <form
      className="grid gap-xl md:grid-cols-[auto_1fr]"
      onSubmit={(e) => (e.preventDefault(), void guardar())}
    >
      <SelloYDocumento perfil={perfil} datos={datos} />
      <div className="flex flex-col gap-m">
        {CAMPOS.map((c) => (
          <Campo
            key={c.clave}
            etiqueta={c.etiqueta}
            type={c.tipo === 'email' ? 'email' : 'text'}
            inputMode={c.tipo === 'email' ? undefined : (c.tipo as 'tel' | 'url' | undefined)}
            value={datos[c.clave]}
            onChange={(e) => setDatos({ ...datos, [c.clave]: e.target.value })}
          />
        ))}
        <p className="text-pequeno text-tinta-suave">
          Mientras no tengas logo, tu sello lleva la inicial del negocio.
        </p>
        {problema && <Aviso tono="error">{problema}</Aviso>}
        {guardado && <Aviso tono="exito">Listo, veci. Así queda tu negocio.</Aviso>}
        <Boton type="submit" disabled={ocupado} className="self-start">
          Guardar cambios
        </Boton>
      </div>
    </form>
  );
}

/** Datos del negocio (HU-03-01): el documento no se cambia aquí, lo demás sí. */
export function MiNegocio({ repositorio }: { repositorio: RepositorioComercios }) {
  const cargar = useCallback(() => repositorio.perfil(), [repositorio]);
  const { estado } = useCarga(cargar);
  if (estado.tipo === 'cargando')
    return <p className="text-cuerpo text-tinta-suave">Un momento, veci…</p>;
  if (estado.tipo === 'error') return <Aviso tono="error">{estado.mensaje}</Aviso>;
  return <Formulario perfil={estado.datos} repositorio={repositorio} />;
}
