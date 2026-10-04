/** Una acción sensible que queda en la bitácora inmutable (RNF-SEG-05). */
export interface EntradaAuditoria {
  /** Código del catálogo audit.actions, por ejemplo PIN_RESET. */
  readonly accion: string;
  readonly tabla: string;
  readonly entidadId: string | null;
  readonly actorUsuarioId: string | null;
  /** Comercio afectado; null para acciones de plataforma o de inicio de sesión. */
  readonly comercioId: string | null;
  readonly dispositivoId?: string | null;
  readonly antes?: Readonly<Record<string, unknown>>;
  readonly despues?: Readonly<Record<string, unknown>>;
}

export interface Auditoria {
  registrar(entrada: EntradaAuditoria): Promise<void>;
}

export const AUDITORIA = Symbol('Auditoria');
