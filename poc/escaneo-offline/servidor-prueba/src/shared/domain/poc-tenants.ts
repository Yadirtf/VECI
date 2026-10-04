/**
 * Comercios fijos de la prueba de concepto. En el MVP salen de tenancy.tenants;
 * aquí son constantes para que el celular y el servidor coincidan sin login.
 */
export const POC_TENANTS = {
  /** Restaurante del cajero que usa la app. */
  own: '01920000-0000-7000-8000-000000000001',
  /** Otro restaurante: sus QR deben rechazarse en la caja del primero. */
  other: '01920000-0000-7000-8000-000000000002',
} as const;
