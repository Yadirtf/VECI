import { Campo } from '@/shared/ui';

export interface CampoPinProps {
  etiqueta: string;
  valor: string;
  alCambiar(valor: string): void;
  nuevo?: boolean;
  ayuda?: string;
}

/** PIN de 6 números: teclado numérico, oculto y sin letras. */
export function CampoPin({ etiqueta, valor, alCambiar, nuevo = false, ayuda }: CampoPinProps) {
  return (
    <Campo
      etiqueta={etiqueta}
      type="password"
      inputMode="numeric"
      autoComplete={nuevo ? 'new-password' : 'current-password'}
      maxLength={6}
      ayuda={ayuda}
      value={valor}
      onChange={(e) => alCambiar(e.target.value.replace(/\D/g, ''))}
    />
  );
}
