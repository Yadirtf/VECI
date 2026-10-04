# Imagen de la API de VECI (HU-01-08). Se construye desde la carpeta backend:
#   docker build -t veci-api .
# Al arrancar aplica las migraciones pendientes (DATABASE_URL, dueño) y luego levanta
# la API con el usuario sujeto a RLS (DATABASE_APP_URL).
FROM node:22-slim AS base
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH CI=true
RUN corepack enable
WORKDIR /app

FROM base AS construccion
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm db:cliente && pnpm build

FROM base AS ejecucion
ENV NODE_ENV=production
COPY --from=construccion /app /app
ARG VECI_VERSION=local
ENV VECI_VERSION=$VECI_VERSION
USER node
EXPOSE 3000
CMD ["pnpm", "start:prod"]
