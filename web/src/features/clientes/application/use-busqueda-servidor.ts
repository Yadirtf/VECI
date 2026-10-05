'use client';

import { useEffect, useState } from 'react';
import type { ClienteEnLibreta, RepositorioClientes } from '../domain/cliente';
import { buscaEnServidor } from '../domain/reglas-clientes';

interface Resultado {
  texto: string;
  clientes: ClienteEnLibreta[];
  problema: string | null;
}

const NADA: Resultado = { texto: '', clientes: [], problema: null };

/**
 * Desde 3 letras o números pregunta también al servidor, que reconoce el documento o el
 * celular completos. Espera a que la persona deje de escribir y descarta respuestas viejas.
 */
export function useBusquedaEnServidor(
  repositorio: RepositorioClientes,
  texto: string,
  espera = 250,
) {
  const [resultado, setResultado] = useState<Resultado>(NADA);

  useEffect(() => {
    if (!buscaEnServidor(texto)) return;
    let vigente = true;
    const reloj = setTimeout(() => {
      repositorio
        .buscar(texto.trim())
        .then((clientes) => vigente && setResultado({ texto, clientes, problema: null }))
        .catch((e: unknown) => {
          const problema = e instanceof Error ? e.message : null;
          if (vigente) setResultado({ texto, clientes: [], problema });
        });
    }, espera);
    return () => {
      vigente = false;
      clearTimeout(reloj);
    };
  }, [repositorio, texto, espera]);

  const alDia = resultado.texto === texto;
  return {
    clientes: alDia ? resultado.clientes : [],
    problema: alDia ? resultado.problema : null,
    buscando: buscaEnServidor(texto) && !alDia,
  };
}
