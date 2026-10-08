/** Solicitud de registro de negocio tal como la revisa Administración VECI (ADR-0019). */
export interface SolicitudPorRevisar {
  solicitudId: string;
  nombre: string;
  tipoNegocio: string;
  tipoDocumento: string;
  numeroDocumento: string;
  celular: string;
  correo: string | null;
  municipio: string;
  direccion: string | null;
  solicitante: { nombre: string; celular: string | null };
  radicadaEn: Date;
}

/** La consola VECI en el API; la infraestructura decide cómo llegar. */
export interface RepositorioPlataforma {
  pendientes(): Promise<SolicitudPorRevisar[]>;
  aprobar(solicitudId: string): Promise<void>;
  rechazar(solicitudId: string, motivo: string): Promise<void>;
}

/** Revisión amable del motivo de rechazo; la regla de verdad está en el servidor. */
export function problemaConMotivo(motivo: string): string | null {
  return motivo.trim().length >= 10
    ? null
    : 'Cuéntale a la persona por qué, en una frase (10 letras o más).';
}

/** Documento legible: el NIT con su dígito separado (900.123.456-7). */
export function documentoLegible(tipo: string, numero: string): string {
  if (tipo !== 'NIT' || numero.length < 2) return `${tipo} ${numero}`;
  const base = numero.slice(0, -1).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  return `NIT ${base}-${numero.slice(-1)}`;
}
