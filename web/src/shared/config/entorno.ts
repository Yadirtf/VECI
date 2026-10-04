/**
 * Variables públicas del panel. Mientras llega el inicio de sesión (EP-02), el panel
 * usa un negocio y un usuario de ejemplo en desarrollo y staging.
 */
export const entorno = {
  urlApi: process.env.NEXT_PUBLIC_VECI_API_URL ?? 'http://localhost:3000',
  comercioDemoId:
    process.env.NEXT_PUBLIC_VECI_COMERCIO_DEMO ?? 'd1000000-0000-7000-8000-000000000001',
  usuarioDemoId:
    process.env.NEXT_PUBLIC_VECI_USUARIO_DEMO ?? 'd4000000-0000-7000-8000-000000000001',
  version: process.env.NEXT_PUBLIC_VECI_VERSION ?? 'local',
} as const;
