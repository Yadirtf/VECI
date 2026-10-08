import { Client } from 'pg';
import request from 'supertest';
import { crearUsuario } from './personas';

type App = Parameters<typeof request>[0];

/** Un usuario del equipo VECI con el rol indicado (Administración por defecto). */
export async function crearEquipoVeci(
  dueno: Client,
  rol: 'VECI_ADMIN' | 'VECI_SUPPORT' = 'VECI_ADMIN',
): Promise<string> {
  const usuarioId = await crearUsuario(dueno);
  await dueno.query(
    `INSERT INTO identity.user_platform_roles (user_id, role_id)
     SELECT $1, id FROM identity.roles WHERE code = $2`,
    [usuarioId, rol],
  );
  return usuarioId;
}

/**
 * Registra un negocio como en producción (ADR-0019): la persona lo solicita y
 * Administración VECI lo aprueba. Devuelve la respuesta de la aprobación.
 */
export async function registrarNegocio(
  servidor: App,
  adminId: string,
  usuarioId: string,
  datos: object,
): Promise<{ body: { comercioId: string; slug: string } }> {
  const persona = { 'x-veci-usuario': usuarioId };
  await request(servidor).post('/solicitudes-de-negocio').set(persona).send(datos).expect(204);
  const mias = await request(servidor).get('/solicitudes-de-negocio').set(persona).expect(200);
  const pendiente = mias.body.find((s: { estado: string }) => s.estado === 'PENDING');
  return request(servidor)
    .post(`/plataforma/solicitudes-de-negocio/${pendiente.solicitudId}/aprobacion`)
    .set({ 'x-veci-usuario': adminId })
    .expect(201);
}
