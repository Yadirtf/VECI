'use client';

import { crearClienteVeci } from '@/shared/api/cliente';
import { useMemo } from 'react';
import { entorno } from '@/shared/config/entorno';
import { RepositorioHorariosApi } from './infrastructure/repositorio-horarios-api';
import { HorariosSemana } from './presentation/horarios-semana';

/**
 * Conecta las piezas de la funcionalidad (como un *.module.ts de NestJS): la página
 * solo usa este componente. Módulo de ejemplo de la arquitectura limpia (HU-01-10).
 */
export function PantallaHorarios() {
  const repositorio = useMemo(
    () =>
      new RepositorioHorariosApi(
        crearClienteVeci({ urlBase: entorno.urlApi, usuarioDesarrolloId: entorno.usuarioDemoId }),
        entorno.comercioDemoId,
      ),
    [],
  );
  return <HorariosSemana repositorio={repositorio} />;
}
