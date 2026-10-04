import { hash } from '@node-rs/argon2';
import { randomUUID } from 'node:crypto';
import { Client } from 'pg';
import request from 'supertest';

type App = Parameters<typeof request>[0];

export const PIN_DE_PRUEBA = '246813';

let hashDelPin: Promise<string> | undefined;
const hashPin = () => (hashDelPin ??= hash(PIN_DE_PRUEBA, { memoryCost: 19456, timeCost: 2 }));

/** Celular colombiano aleatorio, como lo escribiría la persona (10 dígitos). */
export function celularAleatorio(): string {
  return `3${String(Math.floor(100_000_000 + Math.random() * 899_999_999))}`;
}

/** Le da al usuario un celular para entrar y el PIN de prueba. Devuelve el celular. */
export async function darAcceso(dueno: Client, usuarioId: string): Promise<string> {
  const celular = celularAleatorio();
  await dueno.query(
    `INSERT INTO identity.user_login_identifiers (user_id, contact_type_id, value, verified_at)
     SELECT $1, id, $2, now() FROM core.contact_types WHERE code = 'MOBILE_PHONE'`,
    [usuarioId, `+57${celular}`],
  );
  await dueno.query(
    `INSERT INTO identity.user_credentials (user_id, credential_type_id, secret_hash)
     SELECT $1, id, $2 FROM identity.credential_types WHERE code = 'PIN'`,
    [usuarioId, await hashPin()],
  );
  return celular;
}

export const dispositivo = (plataforma: 'ANDROID' | 'WEB' = 'ANDROID') => ({
  id: randomUUID(),
  plataforma,
  modelo: plataforma === 'WEB' ? undefined : 'Moto E13',
});

export type Dispositivo = ReturnType<typeof dispositivo>;

export function entrarConPin(servidor: App, celular: string, pin: string, d = dispositivo()) {
  return request(servidor).post('/sesion/con-pin').send({ celular, pin, dispositivo: d });
}

/** Entra con PIN y elige el comercio; devuelve las cabeceras listas para usar. */
export async function entrarAlComercio(
  servidor: App,
  celular: string,
  comercioId: string,
  d = dispositivo(),
): Promise<{ authorization: string; 'x-veci-comercio': string; tokenRenovacion: string }> {
  const ingreso = await entrarConPin(servidor, celular, PIN_DE_PRUEBA, d).expect(200);
  const { tokenAcceso, tokenRenovacion } = ingreso.body.sesion;
  const authorization = `Bearer ${tokenAcceso}`;
  await request(servidor)
    .post('/cuenta/comercio-activo')
    .set({ authorization })
    .send({ comercioId })
    .expect(200);
  return { authorization, 'x-veci-comercio': comercioId, tokenRenovacion };
}
