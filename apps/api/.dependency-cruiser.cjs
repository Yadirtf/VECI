// Límites entre capas y módulos de la API (sección 5.3 y HU-01-10).
// Se ejecuta en CI con: pnpm --filter @veci/api arquitectura
/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: 'dominio-puro',
      comment:
        'El dominio solo importa dominio: nada de aplicación, infraestructura, presentación ni paquetes.',
      severity: 'error',
      from: { path: '^src/.*/domain/' },
      to: {
        pathNot: ['^src/(shared|modules/[^/]+)/domain/'],
      },
    },
    {
      name: 'aplicacion-sin-detalles',
      comment:
        'La aplicación depende del dominio y de puertos, no de infraestructura ni presentación.',
      severity: 'error',
      from: { path: '^src/.*/application/' },
      to: { path: ['/infrastructure/', '/presentation/', '^generated/', 'node_modules'] },
    },
    {
      name: 'infraestructura-sin-presentacion',
      severity: 'error',
      from: { path: '^src/.*/infrastructure/' },
      to: { path: '/presentation/' },
    },
    {
      name: 'presentacion-sin-infraestructura',
      comment:
        'Controladores y guards usan casos de uso y puertos; el *.module.ts conecta la infraestructura.',
      severity: 'error',
      from: { path: '^src/.*/presentation/' },
      to: { path: ['/infrastructure/', '^generated/'] },
    },
    {
      name: 'modulos-por-su-interfaz-publica',
      comment: 'Un módulo no importa archivos internos de otro: solo su index.ts.',
      severity: 'error',
      from: { path: '^src/modules/([^/]+)/' },
      to: {
        path: '^src/modules/[^/]+/',
        pathNot: ['^src/modules/$1/', '^src/modules/[^/]+/index\\.ts$'],
      },
    },
    {
      name: 'shared-no-conoce-modulos',
      severity: 'error',
      from: { path: '^src/shared/' },
      to: { path: '^src/modules/' },
    },
    { name: 'sin-ciclos', severity: 'error', from: {}, to: { circular: true } },
  ],
  options: {
    doNotFollow: { path: ['node_modules', '^generated/'] },
    exclude: { path: '\\.spec\\.ts$|\\.fake\\.ts$' },
    tsConfig: { fileName: 'tsconfig.json' },
    tsPreCompilationDeps: true,
  },
};
