// Reglas de arquitectura limpia (sección 5.3 del documento de requerimientos).
import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist', 'node_modules'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      'max-lines': ['error', { max: 300, skipBlankLines: false, skipComments: false }],
      'max-lines-per-function': ['error', { max: 50 }],
      'max-params': ['error', 5],
    },
  },
  {
    // El dominio no conoce NestJS, Express ni Node.
    files: ['src/**/domain/**/*.ts'],
    rules: {
      'no-restricted-imports': ['error', { patterns: ['@nestjs/*', 'express', 'node:*', 'crypto', 'qrcode'] }],
    },
  },
);
