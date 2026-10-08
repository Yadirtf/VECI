'use client';

import { Boton } from '@/shared/ui';
import { horaLegible } from '../domain/agrupar-por-dia';
import { aHora } from '../domain/arco';
import type { Horario } from '../domain/horario';
import { planDeProgramacion, type DiaDelPlan, type Rango } from '../domain/programacion';
import { DiasElegibles } from './dias-elegibles';

/** "lunes, martes y jueves" */
function lista(plan: DiaDelPlan[]): string {
  const nombres = plan.map((d) => d.nombre.toLowerCase());
  return nombres.length < 2
    ? (nombres[0] ?? '')
    : `${nombres.slice(0, -1).join(', ')} y ${nombres.at(-1)}`;
}

function Resumen({ plan }: { plan: DiaDelPlan[] }) {
  const de = (accion: DiaDelPlan['accion']) => plan.filter((d) => d.accion === accion && !d.cruce);
  const lineas = [
    de('crear').length > 0 && `Se agrega el ${lista(de('crear'))}.`,
    de('cambiar').length > 0 && `Cambian las horas del ${lista(de('cambiar'))}.`,
    de('igual').length > 0 && `El ${lista(de('igual'))} ya está así.`,
  ].filter(Boolean);
  const cruces = plan.filter((d) => d.cruce);
  return (
    <div aria-live="polite" className="flex flex-col gap-xs text-cuerpo">
      {lineas.map((l) => (
        <p key={String(l)} className="text-tinta-suave">
          {l}
        </p>
      ))}
      {cruces.map(({ dia, nombre, cruce }) => (
        <p key={dia} role="alert" className="font-medio text-arcilla">
          El {nombre.toLowerCase()} se cruza con {cruce?.servicioNombre} (
          {horaLegible(cruce?.horaInicio ?? '')} a {horaLegible(cruce?.horaFin ?? '')}). Cambia las
          horas o quita ese día.
        </p>
      ))}
    </div>
  );
}

function etiqueta(plan: DiaDelPlan[]): string {
  if (plan.length === 0) return 'Elige al menos un día';
  if (plan.length === 1) return `Guardar en ${plan[0].nombre.toLowerCase()}`;
  return plan.length === 7 ? 'Guardar en toda la semana' : `Guardar en ${plan.length} días`;
}

interface Props {
  deLaSede: readonly Horario[];
  servicioId: string | null;
  rango: Rango;
  dias: string[];
  alCambiarDias(dias: string[]): void;
  ocupado: boolean;
  /** false deja guardar aunque todo esté igual (falta, por ejemplo, el nombre). */
  listo?: boolean;
  alGuardar(dias: string[]): void;
}

/**
 * Elegir en qué días quedan esas horas y guardarlas de una vez (HU-03-02). Avisa
 * antes de guardar qué días se agregan, cuáles cambian y cuáles se cruzan.
 */
export function GuardarEnDias(p: Props) {
  const plan = planDeProgramacion(p.deLaSede, p.servicioId, p.dias, p.rango);
  const pendiente = plan.some((d) => d.accion !== 'igual');
  const puede =
    (p.listo ?? true) && pendiente && plan.length > 0 && !plan.some((d) => d.cruce) && !p.ocupado;
  return (
    <div className="flex flex-col gap-m">
      <DiasElegibles elegidos={p.dias} alCambiar={p.alCambiarDias} />
      <p className="text-cuerpo">
        De <strong>{horaLegible(aHora(p.rango.inicio))}</strong> a{' '}
        <strong>{horaLegible(aHora(p.rango.fin))}</strong>
      </p>
      <Resumen plan={plan} />
      <Boton disabled={!puede} className="self-start" onClick={() => p.alGuardar(p.dias)}>
        {etiqueta(plan)}
      </Boton>
    </div>
  );
}
