import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import { reglasDeTamano } from '../../tools/eslint/reglas-arquitectura.mjs';

export default tseslint.config(
  // esquema.ts lo genera openapi-typescript: no se edita ni se mide.
  { ignores: ['dist', 'src/esquema.ts'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  reglasDeTamano,
);
