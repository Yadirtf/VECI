// Límites entre capas y funcionalidades del panel (sección 5.3.3 y HU-01-10).
/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: 'dominio-puro',
      severity: 'error',
      from: { path: '^src/features/[^/]+/domain/' },
      to: { pathNot: ['^src/features/[^/]+/domain/'] },
    },
    {
      name: 'aplicacion-sin-detalles',
      severity: 'error',
      from: { path: '^src/features/[^/]+/application/' },
      to: { path: ['/infrastructure/', '/presentation/', '^src/shared/api/', 'openapi-fetch'] },
    },
    {
      name: 'presentacion-sin-infraestructura',
      comment:
        'Los componentes no conocen el API; el archivo *.composicion.tsx conecta las piezas.',
      severity: 'error',
      from: { path: '^src/features/[^/]+/presentation/' },
      to: { path: ['/infrastructure/', '^src/shared/api/'] },
    },
    {
      name: 'paginas-sin-infraestructura',
      severity: 'error',
      from: { path: '^src/app/' },
      to: { path: ['/infrastructure/', '^src/shared/api/'] },
    },
    {
      name: 'funcionalidades-por-su-interfaz-publica',
      severity: 'error',
      from: { path: '^src/features/([^/]+)/' },
      to: {
        path: '^src/features/[^/]+/',
        pathNot: ['^src/features/$1/', '^src/features/[^/]+/index\\.ts$'],
      },
    },
    {
      name: 'shared-no-conoce-funcionalidades',
      severity: 'error',
      from: { path: '^src/shared/' },
      to: { path: '^src/features/' },
    },
    { name: 'sin-ciclos', severity: 'error', from: {}, to: { circular: true } },
  ],
  options: {
    doNotFollow: { path: 'node_modules' },
    exclude: { path: '\\.test\\.tsx?$' },
    tsConfig: { fileName: 'tsconfig.json' },
    tsPreCompilationDeps: true,
  },
};
