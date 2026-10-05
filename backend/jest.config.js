// Pruebas de la API (HU-01-02). Unitarias sin base de datos; de integración contra
// PostgreSQL real (DATABASE_URL para el dueño y DATABASE_APP_URL para veci_api).
const comun = {
  testEnvironment: 'node',
  transform: {
    '^.+\\.ts$': ['ts-jest', { diagnostics: { ignoreCodes: [151002] } }],
  },
  moduleFileExtensions: ['ts', 'js', 'json'],
};

module.exports = {
  projects: [
    { ...comun, displayName: 'unitarias', roots: ['<rootDir>/src'], testMatch: ['**/*.spec.ts'] },
    {
      ...comun,
      displayName: 'integracion',
      roots: ['<rootDir>/test'],
      testMatch: ['**/*.int-spec.ts'],
      testTimeout: 30000,
    },
  ],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/main.ts',
    '!src/instrument.ts',
    '!src/cargar-entorno.ts',
    '!src/**/*.module.ts',
    '!src/**/index.ts',
    '!src/**/*.fake.ts',
  ],
  coverageReporters: ['text-summary', 'json-summary', 'lcov'],
  // Meta de RNF-MAN-01: 70 % en el núcleo. Cada módulo del núcleo (tiqueteras,
  // consumos, sincronizacion) agrega aquí su umbral cuando nace.
  coverageThreshold: {
    global: { lines: 70, statements: 70, functions: 70, branches: 60 },
    './src/modules/horarios/': { lines: 70, statements: 70, functions: 70, branches: 60 },
    './src/modules/autenticacion/': { lines: 80, statements: 80, functions: 80, branches: 70 },
    './src/modules/personal/': { lines: 80, statements: 80, functions: 80, branches: 70 },
    './src/modules/soporte/': { lines: 80, statements: 80, functions: 80, branches: 70 },
    './src/modules/clientes/': { lines: 80, statements: 80, functions: 80, branches: 70 },
  },
};
