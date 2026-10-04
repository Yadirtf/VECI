import type { AccionMiembro, Dispositivo, EstadoMiembro, Miembro } from './equipo';

export type OpcionMiembro = AccionMiembro | 'RESTABLECER_PIN';

const OPCIONES: Record<EstadoMiembro, readonly OpcionMiembro[]> = {
  INVITED: ['RESTABLECER_PIN', 'RETIRAR'],
  ACTIVE: ['RESTABLECER_PIN', 'SUSPENDER', 'RETIRAR'],
  SUSPENDED: ['REACTIVAR', 'RETIRAR'],
  REMOVED: [],
};

export const esCajero = (m: Miembro) => m.roles.includes('CASHIER') && !m.roles.includes('OWNER');

/** Qué puede hacer la propietaria con cada persona; a otros propietarios no se les toca aquí. */
export function opcionesPara(miembro: Miembro): readonly OpcionMiembro[] {
  return esCajero(miembro) ? OPCIONES[miembro.estado] : [];
}

export const TEXTO_OPCION: Record<OpcionMiembro, string> = {
  RESTABLECER_PIN: 'Darle un PIN nuevo',
  SUSPENDER: 'Suspender',
  REACTIVAR: 'Reactivar',
  RETIRAR: 'Retirar del equipo',
};

export const TEXTO_ESTADO: Record<EstadoMiembro, string> = {
  INVITED: 'Invitado: aún no ha entrado',
  ACTIVE: 'Activo',
  SUSPENDED: 'Suspendido: no puede entrar',
  REMOVED: 'Retirado',
};

export function textoRol(miembro: Miembro): string {
  return miembro.roles.includes('OWNER') ? 'Propietario' : 'Cajero';
}

/** +573100000102 → 310 000 0102, como lo escribe la gente. */
export function celularLegible(celular: string | null): string {
  if (!celular) return 'Sin celular';
  const d = celular.replace(/^\+57/, '');
  return d.length === 10 ? `${d.slice(0, 3)} ${d.slice(3, 6)} ${d.slice(6)}` : celular;
}

/** Primero los activos e invitados; los retirados al final. Propietarios arriba. */
export function ordenarEquipo(miembros: readonly Miembro[]): Miembro[] {
  const peso = (m: Miembro) => (m.estado === 'REMOVED' ? 2 : 0) + (esCajero(m) ? 1 : 0);
  return [...miembros].sort((a, b) => peso(a) - peso(b) || a.nombre.localeCompare(b.nombre));
}

/** Dispositivos con sesiones abiertas primero, del más reciente al más antiguo. */
export function ordenarDispositivos(dispositivos: readonly Dispositivo[]): Dispositivo[] {
  return [...dispositivos].sort(
    (a, b) =>
      Number(b.sesiones.length > 0) - Number(a.sesiones.length > 0) ||
      b.ultimaVez.getTime() - a.ultimaVez.getTime(),
  );
}

export function cuantoHace(fecha: Date, ahora: Date): string {
  const minutos = Math.floor((ahora.getTime() - fecha.getTime()) / 60_000);
  if (minutos < 2) return 'ahora mismo';
  if (minutos < 60) return `hace ${minutos} minutos`;
  const horas = Math.floor(minutos / 60);
  if (horas < 24) return horas === 1 ? 'hace 1 hora' : `hace ${horas} horas`;
  const dias = Math.floor(horas / 24);
  return dias === 1 ? 'ayer' : `hace ${dias} días`;
}
