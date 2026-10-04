/** Variables públicas del panel (llegan al navegador; nada secreto aquí). */
export const entorno = {
  urlApi: process.env.NEXT_PUBLIC_VECI_API_URL ?? 'http://localhost:3000',
  version: process.env.NEXT_PUBLIC_VECI_VERSION ?? 'local',
} as const;
