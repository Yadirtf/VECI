import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: { alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) } },
  oxc: { jsx: { runtime: 'automatic' } },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/shared/pruebas/preparar.ts'],
    coverage: {
      include: ['src/features/**', 'src/shared/**'],
      exclude: ['**/*.test.*', 'src/shared/pruebas/**', '**/*.composicion.tsx'],
      reporter: ['text-summary', 'json-summary', 'lcov'],
    },
  },
});
