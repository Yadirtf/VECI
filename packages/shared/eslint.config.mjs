import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import { reglasDeTamano } from '../../tools/eslint/reglas-arquitectura.mjs';

export default tseslint.config(
  { ignores: ['dist'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  reglasDeTamano,
);
