import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      include: ['src/**'],
      exclude: ['**/*.test.*', 'src/index.ts'],
      reporter: ['text-summary', 'json-summary', 'lcov'],
    },
  },
});
