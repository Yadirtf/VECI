'use client';

import type { ReactNode } from 'react';
import { Campo } from '@/shared/ui';
import { serviciosEnPalabras, type BorradorAlta } from '../domain/alta';
import type { Municipio, TipoDeNegocio } from '../domain/comercio';
import { conPuntos, digitoVerificacion, soloDigitos } from '../domain/nit';

export interface PropsPregunta {
  borrador: BorradorAlta;
  cambiar(cambios: Partial<BorradorAlta>): void;
}

export function Pregunta({ titulo, children }: { titulo: string; children: ReactNode }) {
  return (
    <fieldset className="flex flex-col gap-m">
      <legend className="mb-m text-grande font-fuerte leading-tight text-selva-oscuro">
        {titulo}
      </legend>
      {children}
    </fieldset>
  );
}

/** Opción redonda y grande: se toca con el pulgar, no se despliega ninguna lista. */
function Bola(p: { activa: boolean; texto: string; alTocar(): void; pequena?: boolean }) {
  const tamano = p.pequena ? 'min-h-toque-boton px-l' : 'h-28 w-28 sm:h-32 sm:w-32';
  const color = p.activa
    ? 'bg-selva text-superficie border-selva'
    : 'bg-superficie text-selva-oscuro border-borde hover:border-selva';
  return (
    <button
      type="button"
      aria-pressed={p.activa}
      onClick={p.alTocar}
      className={`${tamano} ${color} flex items-center justify-center rounded-total border-2 text-center text-cuerpo font-medio leading-tight transition-colors focus-visible:outline-4 focus-visible:outline-maiz`}
    >
      {p.texto}
    </button>
  );
}

export function PreguntaNombre({ borrador, cambiar }: PropsPregunta) {
  return (
    <Pregunta titulo="¿Cómo se llama tu negocio?">
      <Campo
        etiqueta="Nombre como lo conoce la gente"
        autoFocus
        maxLength={120}
        value={borrador.nombre}
        onChange={(e) => cambiar({ nombre: e.target.value })}
        placeholder="Restaurante La Vecina"
      />
    </Pregunta>
  );
}

export function PreguntaTipo({
  borrador,
  cambiar,
  tipos,
}: PropsPregunta & { tipos: TipoDeNegocio[] }) {
  const elegido = tipos.find((t) => t.codigo === borrador.tipoNegocio);
  return (
    <Pregunta titulo="¿Qué vendes?">
      <div className="flex flex-wrap justify-center gap-m">
        {tipos.map((t, i) => (
          <div key={t.codigo} className={i % 2 ? 'sm:translate-y-6' : ''}>
            <Bola
              activa={t.codigo === borrador.tipoNegocio}
              texto={t.nombre}
              alTocar={() => cambiar({ tipoNegocio: t.codigo })}
            />
          </div>
        ))}
      </div>
      {elegido && elegido.servicios.length > 0 && (
        <p className="mt-l text-cuerpo text-tinta-suave">
          Tu negocio nace con {serviciosEnPalabras(elegido)}. Las horas las eliges después en tu
          camino del sol.
        </p>
      )}
    </Pregunta>
  );
}

export function PreguntaDocumento({ borrador, cambiar }: PropsPregunta) {
  const digitos = soloDigitos(borrador.documento);
  const esNit = borrador.tipoDocumento === 'NIT';
  const listo = esNit && /^\d{8,9}$/.test(digitos);
  return (
    <Pregunta titulo="¿Con qué número está registrado?">
      <div className="flex gap-s">
        <Bola
          pequena
          activa={esNit}
          texto="NIT"
          alTocar={() => cambiar({ tipoDocumento: 'NIT' })}
        />
        <Bola
          pequena
          activa={!esNit}
          texto="Cédula"
          alTocar={() => cambiar({ tipoDocumento: 'CC' })}
        />
      </div>
      <div className="flex items-end gap-s">
        <div className="flex-1">
          <Campo
            etiqueta={esNit ? 'NIT, solo los 9 números' : 'Número de cédula'}
            inputMode="numeric"
            autoComplete="off"
            value={conPuntos(digitos)}
            onChange={(e) =>
              cambiar({ documento: soloDigitos(e.target.value).slice(0, esNit ? 9 : 10) })
            }
          />
        </div>
        {esNit && (
          <span aria-hidden className="mb-s text-grande font-fuerte text-selva">
            -{listo ? digitoVerificacion(digitos) : '?'}
          </span>
        )}
      </div>
      {listo && (
        <p className="text-cuerpo text-selva-oscuro">
          El dígito de verificación es {digitoVerificacion(digitos)}. Lo pusimos nosotros, veci.
        </p>
      )}
    </Pregunta>
  );
}

export function PreguntaContacto({ borrador, cambiar }: PropsPregunta) {
  return (
    <Pregunta titulo="¿A qué número te escribe la gente?">
      <Campo
        etiqueta="Celular del negocio"
        inputMode="tel"
        autoComplete="tel"
        placeholder="310 000 0101"
        value={borrador.celular}
        onChange={(e) => cambiar({ celular: e.target.value })}
      />
      <Campo
        etiqueta="Correo (si tienes)"
        type="email"
        autoComplete="email"
        value={borrador.correo}
        onChange={(e) => cambiar({ correo: e.target.value })}
      />
    </Pregunta>
  );
}

export function PreguntaLugar({
  borrador,
  cambiar,
  municipios,
}: PropsPregunta & { municipios: Municipio[] }) {
  return (
    <Pregunta titulo="¿Dónde queda?">
      <div className="flex flex-wrap gap-s">
        {municipios.map((m) => (
          <Bola
            key={m.id}
            pequena
            activa={m.id === borrador.municipioId}
            texto={m.nombre}
            alTocar={() => cambiar({ municipioId: m.id === borrador.municipioId ? null : m.id })}
          />
        ))}
      </div>
      <Campo
        etiqueta="Dirección o barrio (opcional)"
        value={borrador.direccion}
        onChange={(e) => cambiar({ direccion: e.target.value })}
        placeholder="Barrio San Agustín"
      />
    </Pregunta>
  );
}
