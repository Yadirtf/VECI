import { inicialDe } from '../domain/alta';

/** Borde ondulado de sello: 18 ondas alrededor del círculo. */
function bordeOndulado(r: number, ondas = 18): string {
  const puntos = Array.from({ length: ondas * 2 }, (_, i) => {
    const angulo = (Math.PI * i) / ondas;
    const radio = i % 2 ? r * 0.9 : r;
    return `${50 + radio * Math.cos(angulo)},${50 + radio * Math.sin(angulo)}`;
  });
  return `M ${puntos.join(' L ')} Z`;
}

interface PropsSello {
  nombre: string;
  logoUrl?: string | null;
  tamano?: number;
}

function SelloDeInicial({ nombre, tamano }: { nombre: string; tamano: number }) {
  return (
    <svg
      viewBox="0 0 100 100"
      width={tamano}
      height={tamano}
      role="img"
      aria-label={`Sello de ${nombre}`}
    >
      <path d={bordeOndulado(48)} fill="var(--color-maiz)" />
      <circle cx={50} cy={50} r={36} fill="var(--color-selva-oscuro)" />
      <circle
        cx={50}
        cy={50}
        r={31}
        fill="none"
        stroke="var(--color-maiz)"
        strokeWidth={1.5}
        strokeDasharray="3 3"
      />
      <text
        x={50}
        y={62}
        textAnchor="middle"
        fontSize={34}
        fontWeight={800}
        fill="var(--color-crema)"
      >
        {inicialDe(nombre || 'VECI')}
      </text>
    </svg>
  );
}

/**
 * Sello del negocio: su logo si lo tiene; si no, su inicial en un sello de borde
 * ondulado. Ningún negocio queda sin cara mientras sube su logo.
 */
export function SelloNegocio({ nombre, logoUrl = null, tamano = 96 }: PropsSello) {
  if (!logoUrl) return <SelloDeInicial nombre={nombre} tamano={tamano} />;
  return (
    // eslint-disable-next-line @next/next/no-img-element -- el logo está en el dominio del negocio
    <img
      src={logoUrl}
      alt={`Logo de ${nombre}`}
      width={tamano}
      height={tamano}
      className="rounded-total object-cover"
    />
  );
}
