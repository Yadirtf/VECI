'use client';

import { useMemo } from 'react';
import { useClienteVeci } from '@/features/sesion';
import { RepositorioCuentaApi } from './infrastructure/repositorio-cuenta-api';
import { FormularioCorreo } from './presentation/formulario-correo';
import { FormularioPin } from './presentation/formulario-pin';

export function MiCuenta() {
  const cliente = useClienteVeci();
  const repositorio = useMemo(() => new RepositorioCuentaApi(cliente), [cliente]);
  return (
    <div className="grid gap-l md:grid-cols-2">
      <FormularioPin repositorio={repositorio} />
      <FormularioCorreo repositorio={repositorio} />
    </div>
  );
}
