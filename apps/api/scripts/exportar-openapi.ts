// Exporta el contrato OpenAPI a packages/api-client/openapi.json sin abrir conexiones
// a la base (HU-01-06). Los clientes de TypeScript y Dart se generan desde ese archivo.
import 'reflect-metadata';
import { writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { crearDocumentoOpenApi } from '../src/shared/presentation/http/openapi/documentacion';

const DESTINO = join(__dirname, '..', '..', '..', 'packages', 'api-client', 'openapi.json');

/** Ordena las llaves para que el archivo no cambie si el contrato no cambia. */
function ordenar(valor: unknown): unknown {
  if (Array.isArray(valor)) return valor.map(ordenar);
  if (valor && typeof valor === 'object') {
    const entradas = Object.entries(valor).sort(([a], [b]) => a.localeCompare(b));
    return Object.fromEntries(entradas.map(([llave, v]) => [llave, ordenar(v)]));
  }
  return valor;
}

async function exportar(): Promise<void> {
  const app = await NestFactory.create(AppModule, { logger: false });
  const documento = crearDocumentoOpenApi(app);
  writeFileSync(DESTINO, `${JSON.stringify(ordenar(documento), null, 2)}\n`);
  await app.close();
  console.log(`✔ Contrato OpenAPI exportado a ${DESTINO}`);
}

void exportar();
