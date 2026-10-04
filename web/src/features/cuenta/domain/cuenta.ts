/** Lo que cada persona cambia de su propia cuenta (HU-02-02, HU-02-03). */
export interface RepositorioCuenta {
  cambiarPin(pinActual: string, pinNuevo: string): Promise<void>;
  definirCorreo(correo: string, contrasena: string, pinActual: string): Promise<string>;
}

/** Revisión amable antes de enviar; la regla de verdad (PIN débil, correo en uso) es del servidor. */
export function problemaConPinNuevo(
  actual: string,
  nuevo: string,
  repetido: string,
): string | null {
  if (!/^\d{6}$/.test(actual) || !/^\d{6}$/.test(nuevo)) return 'El PIN son 6 números.';
  if (nuevo !== repetido) return 'Los dos PIN nuevos no coinciden.';
  if (nuevo === actual) return 'El PIN nuevo debe ser distinto al actual.';
  return null;
}

export function problemaConContrasena(correo: string, contrasena: string): string | null {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo.trim())) return 'Revisa el correo, veci.';
  if (contrasena.length < 8) return 'La contraseña debe tener al menos 8 caracteres.';
  return null;
}
