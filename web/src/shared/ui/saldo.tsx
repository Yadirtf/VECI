import { Casillas } from './casillas';

export interface SaldoProps {
  unidades: number;
  singular: string;
  plural: string;
  /** Con el total se dibuja la tiquetera de casillas: las usadas quedan perforadas. */
  total?: number;
}

/** Saldo de una tiquetera en una colilla de boleto: "12 ┆ almuerzos". */
export function Saldo({ unidades, singular, plural, total }: SaldoProps) {
  const unidad = unidades === 1 ? singular : plural;
  const etiqueta = `Saldo: ${unidades} ${unidad}${total ? ` de ${total}` : ''}`;
  return (
    <div
      role="img"
      aria-label={etiqueta}
      className="colilla inline-flex flex-col gap-s bg-superficie px-xl py-m text-tinta shadow-[inset_0_0_0_1.5px_var(--color-borde)]"
    >
      <p className="flex items-center gap-m">
        <span className="text-saldo font-fuerte text-selva-oscuro tabular-nums">{unidades}</span>
        <span aria-hidden="true" className="h-11 border-l-2 border-dashed border-borde" />
        <span className="text-titulo font-medio">{unidad}</span>
      </p>
      {total ? <Casillas usadas={total - unidades} total={total} /> : null}
    </div>
  );
}
