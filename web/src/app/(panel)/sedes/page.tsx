import { Sedes } from '@/features/sedes';

export const metadata = { title: 'Sedes · VECI' };

export default function SedesPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Tus sedes</h1>
      <Sedes />
    </>
  );
}
