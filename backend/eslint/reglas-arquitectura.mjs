// Reglas de arquitectura limpia compartidas por la API, el panel y los paquetes
// (sección 5.3.1 del documento de requerimientos y RNF-MAN-03).

/** Archivos de máximo 300 líneas, funciones de máximo 50 y 5 parámetros. */
export const reglasDeTamano = {
  rules: {
    'max-lines': ['error', { max: 300, skipBlankLines: false, skipComments: false }],
    'max-lines-per-function': ['error', { max: 50, skipBlankLines: false, skipComments: false }],
    'max-params': ['error', 5],
  },
};

/** Paquetes que el dominio nunca puede importar: frameworks, base de datos, red y Node. */
export const importacionesProhibidasEnDominio = [
  '@nestjs/*',
  '@prisma/*',
  '@sentry/*',
  'express',
  'pg',
  'next',
  'next/*',
  'react',
  'react-dom',
  'node:*',
  'axios',
  'openapi-fetch',
  '@veci/api-client',
];

/** Regla de ESLint que aplica la lista anterior a los archivos de dominio. */
export function dominioSinFrameworks(archivos) {
  return {
    files: archivos,
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: importacionesProhibidasEnDominio,
              message: 'El dominio no conoce frameworks, base de datos ni red (sección 5.3.1).',
            },
          ],
        },
      ],
    },
  };
}
