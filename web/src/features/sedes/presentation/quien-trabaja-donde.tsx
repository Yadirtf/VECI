import { trabajaEn } from '../domain/reglas-sedes';
import type { CajeroEnSedes, Sede } from '../domain/sede';

/** Cada cajero con sus sedes como fichas que se prenden y apagan (HU-03-03). */
export function QuienTrabajaDonde(p: {
  cajeros: CajeroEnSedes[];
  sedes: Sede[];
  ocupado: boolean;
  alAlternar(c: CajeroEnSedes, sedeId: string): void;
}) {
  const activas = p.sedes.filter((s) => s.activa);
  if (p.cajeros.length === 0)
    return (
      <p className="text-cuerpo text-tinta-suave">
        Cuando invites cajeros, aquí eliges en qué sede atiende cada uno.
      </p>
    );
  return (
    <ul className="flex flex-col gap-m">
      {p.cajeros.map((c) => (
        <li key={c.membresiaId} className="flex flex-wrap items-center gap-s">
          <span className="min-w-40 text-subtitulo font-medio">{c.nombre}</span>
          {activas.map((s) => {
            const aqui = trabajaEn(c, s.id);
            return (
              <button
                key={s.id}
                type="button"
                aria-pressed={aqui}
                disabled={p.ocupado}
                onClick={() => p.alAlternar(c, s.id)}
                className={`min-h-toque-minimo rounded-total border-2 px-m text-cuerpo ${aqui ? 'border-selva bg-selva text-superficie' : 'border-borde bg-superficie text-tinta-suave'}`}
              >
                {s.nombre}
              </button>
            );
          })}
          {c.sedeIds.length === 0 && (
            <span className="text-pequeno text-tinta-suave">(en todas)</span>
          )}
        </li>
      ))}
    </ul>
  );
}
