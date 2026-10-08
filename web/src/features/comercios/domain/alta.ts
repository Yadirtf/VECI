import type { DatosAlta, TipoDeNegocio } from './comercio';
import { digitoVerificacion, soloDigitos } from './nit';

/** Una pregunta por pantalla: así la dueña la contesta entre pedido y pedido. */
export type PasoAlta = 'NOMBRE' | 'TIPO' | 'DOCUMENTO' | 'CONTACTO' | 'LUGAR' | 'LETRERO';

export const PASOS: readonly PasoAlta[] = [
  'NOMBRE',
  'TIPO',
  'DOCUMENTO',
  'CONTACTO',
  'LUGAR',
  'LETRERO',
];

/** Lo que se lleva escrito; se guarda en el navegador por si se va la señal o la luz. */
export interface BorradorAlta {
  nombre: string;
  tipoNegocio: string;
  tipoDocumento: 'NIT' | 'CC';
  /** Solo los números que escribió la persona (sin el dígito del NIT). */
  documento: string;
  celular: string;
  correo: string;
  municipioId: number | null;
  direccion: string;
}

export const BORRADOR_VACIO: BorradorAlta = {
  nombre: '',
  tipoNegocio: '',
  tipoDocumento: 'NIT',
  documento: '',
  celular: '',
  correo: '',
  municipioId: null,
  direccion: '',
};

const CORREO = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

function problemaDocumento(b: BorradorAlta): string | null {
  const digitos = soloDigitos(b.documento);
  if (b.tipoDocumento === 'NIT' && !/^\d{8,9}$/.test(digitos)) {
    return 'Escribe los 9 números del NIT. El dígito de verificación lo ponemos nosotros.';
  }
  if (b.tipoDocumento === 'CC' && !/^\d{6,10}$/.test(digitos)) {
    return 'La cédula tiene de 6 a 10 números.';
  }
  return null;
}

function problemaContacto(b: BorradorAlta): string | null {
  const celular = soloDigitos(b.celular);
  if (celular.length !== 10 || !celular.startsWith('3')) {
    return 'El celular son 10 números y empieza por 3.';
  }
  if (b.correo.trim() && !CORREO.test(b.correo.trim())) return 'Ese correo no parece completo.';
  return null;
}

/** Qué falta para seguir; null = puede avanzar. La regla de verdad vive en el servidor. */
export function problemaEnPaso(paso: PasoAlta, b: BorradorAlta): string | null {
  switch (paso) {
    case 'NOMBRE':
      return b.nombre.trim().length >= 3 ? null : '¿Cómo te conoce la gente? Mínimo 3 letras.';
    case 'TIPO':
      return b.tipoNegocio ? null : 'Toca el que más se parezca a tu negocio.';
    case 'DOCUMENTO':
      return problemaDocumento(b);
    case 'CONTACTO':
      return problemaContacto(b);
    case 'LUGAR':
      return b.municipioId ? null : '¿En qué municipio queda? Por ahora VECI atiende en Mocoa.';
    default:
      return null;
  }
}

/** Documento como lo guarda VECI: el NIT con su dígito al final. */
export function documentoCompleto(b: BorradorAlta): string {
  const digitos = soloDigitos(b.documento);
  return b.tipoDocumento === 'NIT' ? `${digitos}${digitoVerificacion(digitos)}` : digitos;
}

export function aDatosAlta(b: BorradorAlta): DatosAlta {
  return {
    nombre: b.nombre.trim(),
    tipoNegocio: b.tipoNegocio,
    tipoDocumento: b.tipoDocumento,
    numeroDocumento: documentoCompleto(b),
    celular: soloDigitos(b.celular),
    correo: b.correo.trim() || null,
    municipioId: b.municipioId,
    direccion: b.direccion.trim() || null,
  };
}

/** "Desayuno, Almuerzo y Cena" para contarle con qué servicios nace su negocio. */
export function serviciosEnPalabras(tipo: TipoDeNegocio | undefined): string {
  const nombres = tipo?.servicios.map((s) => s.nombre) ?? [];
  if (nombres.length <= 1) return nombres.join('');
  return `${nombres.slice(0, -1).join(', ')} y ${nombres[nombres.length - 1]}`;
}

/** Inicial para el sello del negocio cuando no hay logo. */
export function inicialDe(nombre: string): string {
  const palabras = nombre
    .trim()
    .split(/\s+/)
    .filter(
      (p) => !/^(restaurante|cafeter[ií]a|panader[ií]a|tienda|colegio|el|la|los|las|de)$/i.test(p),
    );
  return (palabras[0] ?? nombre.trim())[0]?.toUpperCase() ?? 'V';
}
