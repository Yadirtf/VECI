import { DatosDelNegocio } from '@/features/comercios';

export const metadata = { title: 'Mi negocio · VECI' };

export default function NegocioPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Mi negocio</h1>
      <DatosDelNegocio />
    </>
  );
}
