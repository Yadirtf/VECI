import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import {
  ContenidoPolitica,
  PoliticaRepository,
  PoliticaVigente,
} from '../../application/puertos/politica.repository';
import { POLITICA_1_0 } from './politica-de-datos-1-0';

/** Textos publicados por versión. Publicar otra = agregar su texto y su fila con la huella. */
export const TEXTOS_POLITICA: Readonly<Record<string, ContenidoPolitica>> = {
  [POLITICA_1_0.version]: POLITICA_1_0,
};

interface FilaVersion {
  id: string;
  version: string;
  publicada_en: Date;
  huella: string;
}

/**
 * compliance.policy_versions guarda versión y huella SHA-256; el texto vive aquí.
 * Si la versión publicada no tiene texto en la API, falla en voz alta: nadie acepta
 * una política que no puede leer.
 */
@Injectable()
export class PrismaPoliticaRepository implements PoliticaRepository {
  constructor(private readonly prisma: PrismaService) {}

  async vigente(): Promise<PoliticaVigente> {
    const [fila] = await this.prisma.$queryRaw<FilaVersion[]>`
      SELECT v.id::text, v.version_label AS version, v.published_at AS publicada_en,
             encode(v.content_sha256, 'hex') AS huella
        FROM compliance.policy_versions v
        JOIN compliance.policy_document_types t ON t.id = v.policy_document_type_id
       WHERE t.code = 'DATA_TREATMENT_POLICY' AND v.published_at <= now()
       ORDER BY v.published_at DESC
       LIMIT 1`;
    const contenido = fila ? TEXTOS_POLITICA[fila.version] : undefined;
    if (!fila || !contenido) throw new Error('No hay texto para la política de datos publicada.');
    return { ...contenido, id: fila.id, publicadaEn: fila.publicada_en, huella: fila.huella };
  }
}
