'use client';

import { useCallback, useState } from 'react';
import { useCarga } from '@/shared/lib/use-carga';
import type { RepositorioClientes, ResultadoRegistro } from '../domain/cliente';
import {
  buscarEnLibreta,
  filtrar,
  juntar,
  ordenarLibreta,
  type FiltroClientes,
} from '../domain/reglas-clientes';
import { useBusquedaEnServidor } from './use-busqueda-servidor';

/** Lo que muestra la ventanilla de la derecha. */
export type Ventanilla =
  { tipo: 'vacia' } | { tipo: 'ficha'; clienteId: string } | { tipo: 'registro'; desde: string };

export interface PinVisible {
  nombre: string;
  pin: string;
}

/** Caso de uso "la libreta de clientes": buscar, filtrar, abrir una ficha o registrar. */
export function useLibreta(repositorio: RepositorioClientes) {
  const cargar = useCallback(() => repositorio.libreta(), [repositorio]);
  const { estado, recargar } = useCarga(cargar);
  const [texto, setTexto] = useState('');
  const [filtro, setFiltro] = useState<FiltroClientes>('TODOS');
  const [ventanilla, setVentanilla] = useState<Ventanilla>({ tipo: 'vacia' });
  const [pin, setPin] = useState<PinVisible | null>(null);
  const [aviso, setAviso] = useState<string | null>(null);
  const servidor = useBusquedaEnServidor(repositorio, texto);

  const todos = estado.tipo === 'listo' ? estado.datos : [];
  const locales = ordenarLibreta(buscarEnLibreta(todos, texto));
  const visibles = filtrar(juntar(locales, servidor.clientes), filtro);

  const abrir = (siguiente: Ventanilla) => {
    setAviso(null);
    setVentanilla(siguiente);
  };

  const registrado = ({ cliente, pinBienvenida, vinculado }: ResultadoRegistro) => {
    setPin(pinBienvenida ? { nombre: cliente.nombres, pin: pinBienvenida } : null);
    setTexto('');
    setVentanilla({ tipo: 'ficha', clienteId: cliente.clienteId });
    setAviso(
      vinculado
        ? `¡Listo! ${cliente.nombres} ya es cliente de tu negocio.`
        : `¡Listo, veci! ${cliente.nombres} quedó en tu libreta.`,
    );
    recargar();
  };

  return {
    estado,
    todos,
    visibles,
    texto,
    setTexto,
    filtro,
    setFiltro,
    servidor,
    ventanilla,
    elegir: (clienteId: string) => abrir({ tipo: 'ficha', clienteId }),
    registrarNuevo: () => abrir({ tipo: 'registro', desde: texto }),
    registrado,
    pin,
    mostrarPin: setPin,
    ocultarPin: () => setPin(null),
    aviso,
  };
}
