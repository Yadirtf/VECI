import { PoliticaDeDatos } from '@/features/clientes';

// Pública: se abre sin sesión, fuera del panel, y se puede imprimir.
export const metadata = {
  title: 'Política de datos · VECI',
  description: 'Cómo cuida VECI los datos de los clientes, en palabras de vecino.',
};

export default function PoliticaDeDatosPage() {
  return <PoliticaDeDatos />;
}
