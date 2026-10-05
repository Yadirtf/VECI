import type { Politica } from '../domain/cliente';

export interface PoliticaEnCortoProps {
  enCorto: Politica['enCorto'];
  /** Encabezado del bloque; en la caja se dice "Léele esto en voz alta". */
  titulo?: string;
}

function Lista({
  titulo,
  items,
  marca,
}: {
  titulo: string;
  items: readonly string[];
  marca: string;
}) {
  return (
    <div>
      <h4 className="text-subtitulo font-fuerte text-tinta">{titulo}</h4>
      <ul className="mt-xs flex flex-col gap-xs text-cuerpo">
        {items.map((item) => (
          <li key={item} className="flex gap-s">
            <span aria-hidden="true" className="font-fuerte text-selva-oscuro">
              {marca}
            </span>
            {item}
          </li>
        ))}
      </ul>
    </div>
  );
}

/** La política de datos "en corto": lo que anotamos, lo que nunca hacemos y para qué. */
export function PoliticaEnCorto({
  enCorto,
  titulo = 'La política en corto',
}: PoliticaEnCortoProps) {
  return (
    <section
      aria-label={titulo}
      className="papelito perforado flex flex-col gap-m px-l pb-l [--papel:var(--color-selva-claro)] print:border print:border-black print:[--papel:#fff]"
    >
      <h3 className="text-titulo font-fuerte text-selva-oscuro">{titulo}</h3>
      <div className="grid gap-m sm:grid-cols-2">
        <Lista titulo="Lo que anotamos" items={enCorto.anotamos} marca="✓" />
        <Lista titulo="Lo que nunca hacemos" items={enCorto.nuncaHacemos} marca="✕" />
      </div>
      <p className="text-cuerpo">
        <strong>¿Para qué?</strong> {enCorto.paraQue}
      </p>
    </section>
  );
}
