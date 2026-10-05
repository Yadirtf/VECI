/** La tiquetera de cartón: una casilla por unidad. Usadas = aro perforado; disponibles = llenas. */
export function Casillas({ usadas, total }: { usadas: number; total: number }) {
  return (
    <ul aria-hidden="true" className="flex max-w-80 flex-wrap gap-xs">
      {Array.from({ length: total }, (_, i) => (
        <li
          key={i}
          className={`size-[18px] rounded-total ${
            i < usadas ? 'border-[3px] border-borde' : 'bg-selva'
          }`}
        />
      ))}
    </ul>
  );
}
