/** Ángulo entre −8° y 8°, estable para la misma semilla (por ejemplo, el id del consumo). */
export function anguloDelSello(semilla: string): number {
  let suma = 0;
  for (const letra of semilla) suma = (suma * 31 + letra.charCodeAt(0)) & 0x7fffffff;
  return (suma % 17) - 8;
}

export interface SelloProps {
  arriba: string;
  cifra: string;
  abajo: string;
  semilla: string;
}

/**
 * El sello de tinta que cae cuando algo quedó registrado. Sale un poco torcido, distinto
 * para cada consumo y siempre igual para el mismo, como en la tiquetera de cartón.
 */
export function Sello({ arriba, cifra, abajo, semilla }: SelloProps) {
  const giro = `${anguloDelSello(semilla)}deg`;
  return (
    <div
      role="status"
      aria-label={`${arriba} ${cifra} ${abajo}`}
      className="sello-cae grid size-50 place-items-center rounded-total border-4 border-selva-oscuro bg-selva-claro p-1.5 text-selva-oscuro"
      style={{ ['--giro' as string]: giro, transform: `rotate(${giro})` }}
    >
      <div className="flex size-full flex-col items-center justify-center rounded-total border-[1.5px] border-selva-oscuro px-l text-center font-fuerte">
        <span className="text-cuerpo">{arriba}</span>
        <span className="text-sello leading-none tabular-nums">{cifra}</span>
        <span className="text-cuerpo">{abajo}</span>
      </div>
    </div>
  );
}
