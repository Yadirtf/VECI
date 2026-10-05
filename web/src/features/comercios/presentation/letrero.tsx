import type { BorradorAlta } from '../domain/alta';
import { documentoCompleto } from '../domain/alta';
import type { TipoDeNegocio } from '../domain/comercio';
import { nitLegible, soloDigitos } from '../domain/nit';
import { SelloNegocio } from './sello';

/**
 * Resumen final como el letrero que cuelga en la puerta: así se ve el negocio antes
 * de registrarlo. Las cuerdas y el clavo son solo trazos.
 */
export function Letrero({ borrador, tipo }: { borrador: BorradorAlta; tipo?: TipoDeNegocio }) {
  const documento = documentoCompleto(borrador);
  return (
    <figure className="mx-auto flex w-full max-w-md flex-col items-center">
      <svg viewBox="0 0 200 40" className="w-2/3" aria-hidden>
        <circle cx={100} cy={6} r={5} fill="var(--color-tinta-suave)" />
        <path
          d="M 100 8 L 30 38 M 100 8 L 170 38"
          stroke="var(--color-arcilla)"
          strokeWidth={2.5}
          fill="none"
        />
      </svg>
      <div className="-mt-1 flex w-full flex-col items-center gap-s rounded-l border-4 border-arcilla bg-arcilla-claro px-l pb-l pt-m text-center [transform:rotate(-1.2deg)]">
        <SelloNegocio nombre={borrador.nombre} tamano={88} />
        <p className="text-grande font-fuerte leading-tight text-tinta">{borrador.nombre.trim()}</p>
        <p className="text-subtitulo text-arcilla">{tipo?.nombre}</p>
        <dl className="mt-s grid grid-cols-[auto_1fr] gap-x-m gap-y-xs text-left text-cuerpo">
          <dt className="font-medio">{borrador.tipoDocumento === 'NIT' ? 'NIT' : 'Cédula'}</dt>
          <dd>{borrador.tipoDocumento === 'NIT' ? nitLegible(documento) : documento}</dd>
          <dt className="font-medio">Celular</dt>
          <dd>{soloDigitos(borrador.celular).replace(/(\d{3})(\d{3})(\d{4})/, '$1 $2 $3')}</dd>
        </dl>
      </div>
      <figcaption className="mt-m text-cuerpo text-tinta-suave">
        Así queda tu negocio. Arranca con 30 días de prueba gratis.
      </figcaption>
    </figure>
  );
}
