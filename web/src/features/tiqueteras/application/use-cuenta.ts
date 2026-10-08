'use client';

import { useCallback, useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { useCarga } from '@/shared/lib/use-carga';
import { problemaDeCorreccion, problemaDelAjuste } from '../domain/reglas-tiqueteras';
import type {
  Correccion,
  EstadoDeCuenta,
  MedioDePago,
  Motivo,
  Pago,
  RepositorioCuentas,
  TipoDeTiquetera,
  Tiquetera,
} from '../domain/tiquetera';

export type Accion =
  { tipo: 'nada' } | { tipo: 'vender' } | { tipo: 'ajustar'; tiquetera: Tiquetera };

interface Listas {
  catalogo: { tipos: TipoDeTiquetera[]; medios: MedioDePago[] } | null;
  motivos: Motivo[] | null;
}

/** El catálogo de venta y los motivos se piden la primera vez que hacen falta. */
function useListas(repositorio: RepositorioCuentas) {
  const [listas, setListas] = useState<Listas>({ catalogo: null, motivos: null });
  const preparar = async (accion: Accion) => {
    if (accion.tipo === 'vender' && !listas.catalogo) {
      const catalogo = await repositorio.catalogo();
      setListas((l) => ({ ...l, catalogo }));
    }
    if (accion.tipo === 'ajustar' && !listas.motivos) {
      const motivos = await repositorio.motivos();
      setListas((l) => ({ ...l, motivos }));
    }
  };
  return { ...listas, preparar };
}

type Ejecutor = ReturnType<typeof useAccion>;

/** Vender y ajustar; cada uno revisa antes de llamar al servidor. */
function useOperaciones(
  repositorio: RepositorioCuentas,
  clienteId: string,
  nuevoId: () => string,
  { setProblema, ejecutar }: Ejecutor,
  hecho: (cuenta: EstadoDeCuenta, mensaje: string) => void,
) {
  const [ventaId, setVentaId] = useState(nuevoId);

  const vender = (tipo: TipoDeTiquetera, pago: Pago | string) => {
    if (typeof pago === 'string') return setProblema(pago);
    const venta = { ventaId, clienteId, tipoId: tipo.tipoId, precio: tipo.precio, pago };
    void ejecutar(async () => {
      const cuenta = await repositorio.vender(venta);
      setVentaId(nuevoId());
      hecho(cuenta, `Vendida: «${tipo.nombre}». El saldo ya está cargado.`);
    });
  };

  const ajustar = (tiquetera: Tiquetera, unidades: number, correccion: Correccion) => {
    const falta = problemaDelAjuste(tiquetera, unidades) ?? problemaDeCorreccion(correccion);
    if (falta) return setProblema(falta);
    void ejecutar(async () => {
      const cuenta = await repositorio.ajustar(tiquetera.tiqueteraId, unidades, correccion);
      hecho(cuenta, 'Ajuste guardado. Queda en la historia con el motivo.');
    });
  };

  return { vender, ajustar };
}

/**
 * Caso de uso "la cuenta del cliente" (HU-05-02, HU-05-03, HU-05-05): ver su saldo y su
 * historia, venderle una tiquetera y ajustar con motivo. El panel pone el id de la venta,
 * así un doble clic o un reintento no la cobra dos veces.
 */
export function useCuenta(
  repositorio: RepositorioCuentas,
  clienteId: string,
  nuevoId: () => string,
) {
  const cargar = useCallback(() => repositorio.cuenta(clienteId), [repositorio, clienteId]);
  const { estado } = useCarga(cargar);
  const [nueva, setNueva] = useState<EstadoDeCuenta | null>(null);
  const [accion, setAccion] = useState<Accion>({ tipo: 'nada' });
  const [aviso, setAviso] = useState<string | null>(null);
  const listas = useListas(repositorio);
  const ejecutor = useAccion();
  const { ocupado, problema, setProblema, ejecutar } = ejecutor;

  const hecho = (cuenta: EstadoDeCuenta, mensaje: string) => {
    setNueva(cuenta);
    setAccion({ tipo: 'nada' });
    setAviso(mensaje);
  };
  const { vender, ajustar } = useOperaciones(repositorio, clienteId, nuevoId, ejecutor, hecho);

  const abrir = (siguiente: Accion) =>
    void ejecutar(async () => {
      setAviso(null);
      await listas.preparar(siguiente);
      setAccion(siguiente);
    });

  const cancelar = () => {
    setProblema(null);
    setAccion({ tipo: 'nada' });
  };

  const cuenta = nueva ?? (estado.tipo === 'listo' ? estado.datos : null);
  const { catalogo, motivos } = listas;
  return {
    estado,
    cuenta,
    accion,
    abrir,
    cancelar,
    catalogo,
    motivos,
    vender,
    ajustar,
    ocupado,
    problema,
    aviso,
  };
}
