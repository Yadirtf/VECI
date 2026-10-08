import { Boton } from '@/shared/ui';

export interface BotonesProps {
  texto: string;
  ocupado: boolean;
  variante?: 'primario' | 'peligro';
  alCancelar(): void;
}

/** Enviar y cancelar al pie de cada formulario. */
export function Botones({ texto, ocupado, variante = 'primario', alCancelar }: BotonesProps) {
  return (
    <div className="flex flex-wrap gap-s">
      <Boton type="submit" variante={variante} disabled={ocupado}>
        {ocupado ? 'Un momento…' : texto}
      </Boton>
      <Boton variante="secundario" onClick={alCancelar}>
        Cancelar
      </Boton>
    </div>
  );
}
