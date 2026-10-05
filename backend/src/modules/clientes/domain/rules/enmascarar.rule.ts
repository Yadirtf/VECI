/**
 * Cómo se muestran los datos a quien no puede verlos completos (HU-04-03, RNF-SEG-04).
 * Largo fijo: "****5678" no deja adivinar cuántos dígitos tiene el documento.
 */
export function enmascararDocumento(numero: string): string {
  return `****${numero.slice(-4)}`;
}

export function enmascararCelular(celular: string): string {
  return `••• ${celular.slice(-4)}`;
}

/** "Luz Marina C.": nombre para confirmar sin exponer apellidos completos. */
export function nombreCorto(nombres: string, apellidos: string | null): string {
  const inicial = apellidos?.trim().charAt(0);
  return inicial ? `${nombres} ${inicial.toUpperCase()}.` : nombres;
}

export function nombreCompleto(nombres: string, apellidos: string | null): string {
  return apellidos ? `${nombres} ${apellidos}` : nombres;
}

/** Minúsculas sin tildes ni espacios de más: "  José  Ñúñez" → "jose nunez". */
export function plegar(texto: string): string {
  return texto.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/\s+/g, ' ').trim();
}
