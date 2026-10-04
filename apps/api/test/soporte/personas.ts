import { randomUUID } from 'node:crypto';
import { Client } from 'pg';

function documentoAleatorio(): string {
  return String(Math.floor(1_000_000_000 + Math.random() * 8_999_999_999));
}

/** Crea una persona con cédula aleatoria y devuelve su id. */
export async function crearPersona(dueno: Client): Promise<string> {
  const personaId = randomUUID();
  await dueno.query(
    `INSERT INTO identity.people (id, document_type_id, document_number, given_names, person_status_id)
     SELECT $1, dt.id, $2, 'Prueba', ps.id FROM core.document_types dt, identity.person_statuses ps
      WHERE dt.code = 'CC' AND ps.code = 'ACTIVE'`,
    [personaId, documentoAleatorio()],
  );
  return personaId;
}

/** Crea una persona con usuario activo y devuelve el id del usuario. */
export async function crearUsuario(dueno: Client): Promise<string> {
  const personaId = await crearPersona(dueno);
  const usuarioId = randomUUID();
  await dueno.query(
    `INSERT INTO identity.users (id, person_id, user_status_id)
     SELECT $1, $2, id FROM identity.user_statuses WHERE code = 'ACTIVE'`,
    [usuarioId, personaId],
  );
  return usuarioId;
}
