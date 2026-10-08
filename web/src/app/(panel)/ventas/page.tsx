import { Ventas } from '@/features/tiqueteras';

export const metadata = { title: 'Ventas · VECI' };

export default function VentasPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Ventas de tiqueteras</h1>
      <Ventas />
    </>
  );
}
