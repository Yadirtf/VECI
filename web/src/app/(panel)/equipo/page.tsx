import { Equipo } from '@/features/equipo';

export const metadata = { title: 'Equipo · VECI' };

export default function EquipoPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Tu equipo</h1>
      <Equipo />
    </>
  );
}
