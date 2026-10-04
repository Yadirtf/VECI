// Configuración de Prisma (HU-01-03). DATABASE_URL usa el dueño de los esquemas:
// solo migraciones y semillas. La API se conecta con DATABASE_APP_URL (rol veci_app, con RLS).
import { existsSync } from 'node:fs';
import { defineConfig } from 'prisma/config';

if (existsSync('.env')) process.loadEnvFile('.env');

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'ts-node --transpile-only prisma/semillas/sembrar-demo.ts',
  },
  datasource: {
    url: process.env.DATABASE_URL ?? 'postgresql://veci:veci@localhost:5432/veci',
  },
});
