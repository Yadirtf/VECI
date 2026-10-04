import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, OpenAPIObject, SwaggerModule } from '@nestjs/swagger';

/** Contrato OpenAPI generado desde los controladores (HU-01-06). */
export function crearDocumentoOpenApi(app: INestApplication): OpenAPIObject {
  const configuracion = new DocumentBuilder()
    .setTitle('API de VECI')
    .setDescription(
      'El vecino aliado de los negocios del Putumayo. Contrato para la app y el panel.',
    )
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  return SwaggerModule.createDocument(app, configuracion);
}

/** Publica el contrato en /docs y el JSON en /docs/openapi.json (dev y staging). */
export function publicarDocumentacion(app: INestApplication): void {
  SwaggerModule.setup('docs', app, crearDocumentoOpenApi(app), {
    jsonDocumentUrl: 'docs/openapi.json',
  });
}
