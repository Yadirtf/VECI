import { Pizarra } from '@/features/tiqueteras';

export const metadata = { title: 'Tiqueteras · VECI' };

export default function TiqueterasPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Tu pizarra de tiqueteras</h1>
      <Pizarra />
    </>
  );
}
