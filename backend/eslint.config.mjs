// Reglas de arquitectura limpia de la API (sección 5.3 y HU-01-10).
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import { dominioSinFrameworks, reglasDeTamano } from './eslint/reglas-arquitectura.mjs';

export default tseslint.config(
  { ignores: ['dist', 'generated', 'coverage', '*.config.*', '.dependency-cruiser.cjs'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  reglasDeTamano,
  dominioSinFrameworks(['src/**/domain/**/*.ts']),
  {
    // La capa de aplicación tampoco conoce NestJS ni Prisma: los casos de uso son clases
    // simples y el archivo *.module.ts los conecta con useFactory.
    files: ['src/**/application/**/*.ts'],
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@nestjs/*', '@prisma/*', '@sentry/*', 'express', 'pg', '**/generated/**'],
              message: 'La aplicación orquesta el dominio sin framework ni base de datos (5.3.1).',
            },
          ],
        },
      ],
    },
  },
  {
    files: ['**/*.spec.ts', 'test/**/*.ts'],
    rules: { 'max-lines-per-function': 'off' },
  },
);
