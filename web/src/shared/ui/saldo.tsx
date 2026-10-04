/** Saldo de una tiquetera en grande: "12 almuerzos". */
export function Saldo({
  unidades,
  singular,
  plural,
}: {
  unidades: number;
  singular: string;
  plural: string;
}) {
  return (
    <p
      className="flex items-baseline gap-s text-tinta"
      aria-label={`Saldo: ${unidades} ${unidades === 1 ? singular : plural}`}
    >
      <span className="text-saldo font-fuerte text-selva-oscuro">{unidades}</span>
      <span className="text-titulo">{unidades === 1 ? singular : plural}</span>
    </p>
  );
}
