// Reglas de arquitectura limpia del panel (sección 5.3.3 y HU-01-10).
import js from '@eslint/js';
import nextPlugin from '@next/eslint-plugin-next';
import reactHooks from 'eslint-plugin-react-hooks';
import tseslint from 'typescript-eslint';
import { dominioSinFrameworks, reglasDeTamano } from '../../tools/eslint/reglas-arquitectura.mjs';

export default tseslint.config(
  { ignores: ['.next', 'coverage', 'next-env.d.ts'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: { '@next/next': nextPlugin, 'react-hooks': reactHooks },
    rules: {
      ...nextPlugin.configs.recommended.rules,
      ...nextPlugin.configs['core-web-vitals'].rules,
      ...reactHooks.configs.recommended.rules,
    },
  },
  reglasDeTamano,
  dominioSinFrameworks(['src/features/*/domain/**/*.ts', 'src/features/*/domain/**/*.tsx']),
  {
    // Las páginas componen pantallas: no llaman al API (5.3.3).
    files: ['src/app/**/*.tsx'],
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@veci/api-client', '**/infrastructure/**'],
              message:
                'Las páginas usan las pantallas de features/*; el API se llama desde infrastructure.',
            },
          ],
        },
      ],
    },
  },
  {
    // Los componentes no conocen URLs ni HTTP (5.3.3).
    files: ['src/features/*/presentation/**/*.tsx', 'src/features/*/application/**/*.ts'],
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@veci/api-client', 'openapi-fetch', '**/infrastructure/**'],
              message:
                'Presentación y aplicación no conocen el API: usan el repositorio del dominio.',
            },
          ],
        },
      ],
    },
  },
  { files: ['**/*.test.ts', '**/*.test.tsx'], rules: { 'max-lines-per-function': 'off' } },
);
