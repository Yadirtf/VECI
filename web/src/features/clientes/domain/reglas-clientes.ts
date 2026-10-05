import type {
  CanalCliente,
  ClienteEnLibreta,
  CuentaCliente,
  FichaCliente,
  TipoDocumento,
} from './cliente';

export type FiltroClientes = 'TODOS' | 'SIN_APP';

/** Desde cuántas letras o números se pregunta también al servidor (la API pide 3). */
export const BUSQUEDA_MINIMA = 3;

export const TEXTO_CUENTA: Record<CuentaCliente, string> = {
  ACTIVA: 'Usa la app',
  PENDIENTE: 'Falta activar su app',
  SIN_CUENTA: 'Sin app',
};

export const TEXTO_CANAL: Record<CanalCliente, string> = {
  PERSONAL_QR_SCAN: 'Con su QR',
  ASSISTED_REGISTRATION: 'Registrado en el negocio',
  DATA_IMPORT: 'Traído de tu lista anterior',
};

/** "Luz Marína  CHINDOY" → "luz marina chindoy": sin tildes, minúsculas y espacios sencillos. */
export function normalizar(texto: string): string {
  return texto.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/\s+/g, ' ').trim();
}

const soloDigitos = (texto: string) => texto.replace(/\D/g, '');
const esNumero = (texto: string) => /^[\d\s.+-]+$/.test(texto.trim());

export const ultimos4 = (texto: string) => soloDigitos(texto).slice(-4);

/** Tapa un documento o celular completo: 1124505678 → ****5678. Si ya viene tapado, lo deja. */
export function taparDocumento(documento: string): string {
  return documento.includes('*') ? documento : `****${ultimos4(documento)}`;
}

export function taparCelular(celular: string | null): string | null {
  if (!celular) return null;
  return celular.includes('•') ? celular : `••• ${ultimos4(celular)}`;
}

/** "Sin app aún" son quienes todavía no usan la app (cuenta distinta de ACTIVA). */
export function filtrar(clientes: readonly ClienteEnLibreta[], filtro: FiltroClientes) {
  return filtro === 'TODOS' ? [...clientes] : clientes.filter((c) => c.cuenta !== 'ACTIVA');
}

function coincideNumero(c: ClienteEnLibreta, digitos: string): boolean {
  const finales = [c.documentoFinal, c.celularFinal ?? ''].filter(Boolean);
  // Pocos números: parte de los últimos 4. Más: el número completo termina en esos 4.
  if (digitos.length <= 4) return finales.some((f) => f.includes(digitos));
  return finales.some((f) => digitos.endsWith(f));
}

/**
 * Busca en la libreta que ya está en el navegador: por nombre (sin tildes, cada palabra)
 * o por los últimos números del documento o del celular.
 */
export function buscarEnLibreta(
  clientes: readonly ClienteEnLibreta[],
  texto: string,
): ClienteEnLibreta[] {
  const limpio = texto.trim();
  if (!limpio) return [...clientes];
  if (esNumero(limpio)) {
    const digitos = soloDigitos(limpio);
    return clientes.filter((c) => coincideNumero(c, digitos));
  }
  const palabras = normalizar(limpio).split(' ');
  return clientes.filter((c) => palabras.every((p) => c.nombreBusqueda.includes(p)));
}

export const buscaEnServidor = (texto: string) => texto.trim().length >= BUSQUEDA_MINIMA;

/** Lo encontrado aquí primero; lo que el servidor encontró de más, después. Sin repetir. */
export function juntar(
  locales: readonly ClienteEnLibreta[],
  delServidor: readonly ClienteEnLibreta[],
): ClienteEnLibreta[] {
  const vistos = new Set(locales.map((c) => c.clienteId));
  return [...locales, ...delServidor.filter((c) => !vistos.has(c.clienteId))];
}

/** Por nombre, como en una libreta. */
export function ordenarLibreta(clientes: readonly ClienteEnLibreta[]): ClienteEnLibreta[] {
  return [...clientes].sort((a, b) => a.nombreBusqueda.localeCompare(b.nombreBusqueda));
}

export function resumenLibreta(clientes: readonly ClienteEnLibreta[]): string {
  const sinApp = filtrar(clientes, 'SIN_APP').length;
  const total = clientes.length === 1 ? '1 cliente' : `${clientes.length} clientes`;
  return sinApp > 0 ? `${total} · ${sinApp} sin app aún` : total;
}

/** Ficha → renglón de la libreta (lo que trae la búsqueda del servidor o el registro). */
export function aRenglon(f: FichaCliente): ClienteEnLibreta {
  return {
    clienteId: f.clienteId,
    nombre: f.nombre,
    nombreBusqueda: normalizar(f.nombre),
    documento: taparDocumento(f.documento),
    documentoFinal: ultimos4(f.documento),
    celular: taparCelular(f.celular),
    celularFinal: f.celular ? ultimos4(f.celular) : null,
    cuenta: f.cuenta,
    estado: f.estado,
  };
}

/** +573157778888 → 315 777 8888, como lo escribe la gente. Lo tapado queda igual. */
export function celularLegible(celular: string | null): string {
  if (!celular) return 'Sin celular';
  const d = soloDigitos(celular).replace(/^57(?=\d{10}$)/, '');
  return d.length === 10 && !celular.includes('•')
    ? `${d.slice(0, 3)} ${d.slice(3, 6)} ${d.slice(6)}`
    : celular;
}

/** "4 de octubre de 2026", en la hora de Colombia. */
export function fechaLegible(fecha: Date): string {
  return fecha.toLocaleDateString('es-CO', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'America/Bogota',
  });
}

/** Lo que alguien escribió en el buscador sirve para empezar el registro. */
export function datoInicial(texto: string): { numeroDocumento: string; nombres: string } {
  const limpio = texto.trim();
  if (!limpio) return { numeroDocumento: '', nombres: '' };
  return esNumero(limpio)
    ? { numeroDocumento: soloDigitos(limpio), nombres: '' }
    : { numeroDocumento: '', nombres: limpio };
}

/** null si el número sirve para ese tipo de documento; si no, qué revisar. */
export function revisarNumero(numero: string, tipo: TipoDocumento | undefined): string | null {
  const limpio = numero.trim();
  if (!limpio) return 'Escribe el número del documento.';
  if (!tipo?.patron || new RegExp(tipo.patron).test(limpio)) return null;
  return `Revisa el número: no parece de ${tipo.nombre.toLowerCase()}.`;
}

/** Celular colombiano de 10 números que empieza por 3. */
export const celularValido = (celular: string) =>
  /^3\d{9}$/.test(soloDigitos(celular).replace(/^57(?=\d{10}$)/, ''));

/** null si se puede registrar a la persona nueva; si no, qué falta. */
export function faltaEnPersonaNueva(nombres: string, celular: string): string | null {
  if (!nombres.trim()) return 'Escribe su nombre.';
  return celularValido(celular) ? null : 'Revisa el celular: son 10 números y empieza por 3.';
}
