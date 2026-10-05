'use client';

import { useCallback, useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import {
  ProblemaClientes,
  type DatosPersonaNueva,
  type DocumentoPersona,
  type PersonaEncontrada,
  type RepositorioClientes,
  type ResultadoRegistro,
} from '../domain/cliente';

export type PasoRegistro =
  { tipo: 'documento' } | { tipo: 'encontrada'; persona: PersonaEncontrada } | { tipo: 'nueva' };

/** La política vigente (se lee en voz alta y se envía su versión) y los tipos de documento. */
function useCatalogos(repositorio: RepositorioClientes) {
  const cargar = useCallback(async () => {
    const [politica, tipos] = await Promise.all([
      repositorio.politica(),
      repositorio.tiposDocumento(),
    ]);
    return { politica, tipos };
  }, [repositorio]);
  return useCarga(cargar).estado;
}

/**
 * Caso de uso "registro asistido": primero el documento; si la persona ya está en VECI se
 * afilia, si no se anotan sus datos. La política se le lee y el botón es la confirmación.
 */
export function useRegistroAsistido(
  repositorio: RepositorioClientes,
  alRegistrar: (resultado: ResultadoRegistro) => void,
) {
  const catalogos = useCatalogos(repositorio);
  const accion = useAccion();
  const [paso, setPaso] = useState<PasoRegistro>({ tipo: 'documento' });
  const [documento, setDocumento] = useState<DocumentoPersona | null>(null);
  const [celularEnUso, setCelularEnUso] = useState(false);

  const revisar = (doc: DocumentoPersona) =>
    accion.ejecutar(async () => {
      const persona = await repositorio.revisar(doc);
      setDocumento(doc);
      setPaso(persona ? { tipo: 'encontrada', persona } : { tipo: 'nueva' });
    });

  const registrar = (persona: DatosPersonaNueva | null, celularCompartido = false) =>
    accion.ejecutar(async () => {
      if (!documento || catalogos.tipo !== 'listo') return;
      setCelularEnUso(false);
      try {
        const politicaVersionId = catalogos.datos.politica.id;
        const datos = { ...documento, ...persona, celularCompartido, politicaVersionId };
        alRegistrar(await repositorio.registrar(datos));
      } catch (e) {
        if (e instanceof ProblemaClientes && e.codigo === 'CELULAR_EN_USO') setCelularEnUso(true);
        throw e;
      }
    });

  const cambiarDocumento = () => {
    setPaso({ tipo: 'documento' });
    setCelularEnUso(false);
    accion.setProblema(null);
  };

  return {
    catalogos,
    paso,
    documento,
    celularEnUso,
    ocupado: accion.ocupado,
    problema: accion.problema,
    revisar,
    registrar,
    cambiarDocumento,
  };
}
