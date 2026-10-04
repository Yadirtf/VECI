import { PantallaHorarios } from '@/features/horarios';

export const metadata = { title: 'Horarios de servicio · VECI' };

export default function HorariosPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Horarios de servicio</h1>
      <PantallaHorarios />
    </>
  );
}
