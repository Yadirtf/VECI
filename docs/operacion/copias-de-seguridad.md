# Copias de seguridad (HU-01-08, RNF-DIS-02)

## Qué se respalda y dónde

| Capa | Frecuencia | Retención | Dónde |
| --- | --- | --- | --- |
| Historial de Neon (restauración a un punto en el tiempo) | continua | según el plan de Neon | Neon |
| `pg_dump` completo y cifrado (AES-256) | diaria, 03:00 hora de Colombia | **30 días** | artefactos de GitHub Actions ([`respaldo-diario.yml`](../../.github/workflows/respaldo-diario.yml)) |

La copia diaria es independiente del proveedor: si Neon falla o se borra el proyecto, la base se puede levantar en cualquier PostgreSQL 16.

Secretos del entorno `respaldos` en GitHub:

- `DATABASE_URL_RESPALDO`: conexión directa de producción con un rol que **salte RLS** (en Neon, el dueño `neondb_owner` tiene `BYPASSRLS`). Con `veci_api` la copia saldría vacía o fallaría.
- `RESPALDO_CLAVE`: clave larga para cifrar. Guárdela también fuera de GitHub (gestor de contraseñas): sin ella las copias no sirven.

## Prueba de restauración

[`prueba-restauracion.yml`](../../.github/workflows/prueba-restauracion.yml) corre el día 1 de cada mes (y cuando se quiera desde *Actions → Run workflow*):

1. Descarga la última copia diaria exitosa y la descifra.
2. La restaura en un PostgreSQL limpio.
3. Corre [`infra/respaldos/verificar-restauracion.sql`](../../infra/respaldos/verificar-restauracion.sql), que falla si no hay migraciones, si algún saldo en caché no coincide con la suma del libro o si alguna tabla con `tenant_id` perdió su RLS.
4. Deja el resultado en el resumen de la ejecución.

Si la prueba falla, se trata como incidente: las copias de ese período no son confiables hasta corregir la causa.

### Registro de pruebas

| Fecha | Copia | Resultado | Responsable |
| --- | --- | --- | --- |
| 2026-10-04 | Base local con la semilla demo (`pg_dump -Fc` → `pg_restore --no-owner --no-acl`) | ✅ Estructura, saldos y RLS en orden | Claude (PR de EP-01) |

Agregue una fila con cada prueba mensual (o enlace la ejecución de Actions).

## Restaurar producción paso a paso

1. Descargue el artefacto `respaldo-produccion` de la ejecución elegida en *Actions → Respaldo diario*.
2. Descifre:

   ```bash
   gpg --batch --pinentry-mode loopback --passphrase "$RESPALDO_CLAVE" \
     --output veci.dump --decrypt veci-AAAAMMDD-HHMM.dump.gpg
   ```

3. Cree una base vacía (por ejemplo, una rama nueva en Neon) y los roles:

   ```sql
   CREATE ROLE veci_app NOLOGIN NOBYPASSRLS;
   CREATE ROLE veci_platform NOLOGIN BYPASSRLS;
   ```

4. Restaure y compruebe:

   ```bash
   pg_restore --no-owner --no-acl --exit-on-error -d "$URL_NUEVA" veci.dump
   psql "$URL_NUEVA" -v clave_api='...' -f infra/postgres/crear-roles.sql
   psql "$URL_NUEVA" -f infra/respaldos/verificar-restauracion.sql
   ```

   `--no-acl` omite los permisos: vuelva a otorgarlos aplicando el bloque de permisos de `docs/arquitectura/modelo-datos/sql/15_seguridad_rls.sql` (sección «permisos» y el bloque de particiones al final) o restaure sin `--no-acl` si los roles ya existen.
5. Apunte `DATABASE_URL` y `DATABASE_APP_URL` del servicio de Render a la base nueva y redespliegue.

Para errores puntuales (alguien borró o cambió algo) es más rápido usar el historial de Neon: *Branches → Restore* a un minuto anterior.
