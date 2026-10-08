import { Motivo } from '../entities/movimiento';
import { Tiquetera } from '../entities/tiquetera';
import {
  MotivoObligatorio,
  SaldoInsuficiente,
  TiqueteraNoSeAjusta,
} from '../errors/errores-tiqueteras';
import { DatoInvalido } from '../../../../shared/domain/errores/dato-invalido.error';

const MAX_AJUSTE = 500;
const LARGO_NOTA = 500;

/** Motivo de una corrección, ya revisado contra el catálogo. */
export interface MotivoRevisado {
  readonly codigo: string;
  readonly nota: string | null;
}

/**
 * Anular o ajustar exige un motivo del catálogo (RF-TIQ-06). Con "Otro" la nota es
 * obligatoria: alguien que lea la historia después debe entender qué pasó.
 */
export function validarMotivo(
  codigo: string,
  nota: string | null,
  catalogo: readonly Motivo[],
): MotivoRevisado {
  if (!catalogo.some((m) => m.codigo === codigo)) throw new MotivoObligatorio();
  const limpia = nota?.trim().replace(/\s+/g, ' ') || null;
  if (codigo === 'OTHER' && !limpia) {
    throw new MotivoObligatorio('Con "Otro" escribe en una línea qué pasó.');
  }
  if (limpia && limpia.length > LARGO_NOTA) {
    throw new DatoInvalido(`La nota es muy larga (máximo ${LARGO_NOTA} letras).`);
  }
  return { codigo, nota: limpia };
}

/**
 * Un ajuste suma o quita unidades a una tiquetera que todavía sirve (activa o agotada
 * y sin vencer). Nunca la deja en negativo: lo vendido no se puede deber al revés.
 */
export function validarAjuste(tiquetera: Tiquetera, unidades: number, ahora: Date): number {
  if (!Number.isInteger(unidades) || unidades === 0 || Math.abs(unidades) > MAX_AJUSTE) {
    throw new DatoInvalido(`El ajuste va de 1 a ${MAX_AJUSTE} unidades, sumando o quitando.`);
  }
  if (tiquetera.estado === 'VOIDED') throw new TiqueteraNoSeAjusta('anulada');
  const vencida = tiquetera.estado === 'EXPIRED' || tiquetera.venceEn.getTime() <= ahora.getTime();
  if (vencida) throw new TiqueteraNoSeAjusta('vencida');
  if (tiquetera.saldo + unidades < 0) throw new SaldoInsuficiente(Math.max(tiquetera.saldo, 0));
  return unidades;
}
