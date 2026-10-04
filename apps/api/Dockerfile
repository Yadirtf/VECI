# Imagen de la API de VECI (HU-01-08). Se construye desde la raíz del monorepo:
#   docker build -f apps/api/Dockerfile -t veci-api .
# Al arrancar aplica las migraciones pendientes (DATABASE_URL, dueño) y luego levanta
# la API con el usuario sujeto a RLS (DATABASE_APP_URL).
FROM node:22-slim AS base
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH CI=true
RUN corepack enable
WORKDIR /app

FROM base AS construccion
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY apps/api/package.json apps/api/
COPY packages/shared/package.json packages/shared/
RUN pnpm install --frozen-lockfile --filter @veci/api...
COPY packages/shared packages/shared
COPY apps/api apps/api
RUN pnpm --filter @veci/shared build && pnpm --filter @veci/api db:cliente && pnpm --filter @veci/api build

FROM base AS ejecucion
ENV NODE_ENV=production
COPY --from=construccion /app /app
WORKDIR /app/apps/api
ARG VECI_VERSION=local
ENV VECI_VERSION=$VECI_VERSION
USER node
EXPOSE 3000
CMD ["pnpm", "start:prod"]
