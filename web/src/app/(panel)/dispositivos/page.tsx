import { Dispositivos } from '@/features/equipo';

export const metadata = { title: 'Dispositivos · VECI' };

export default function DispositivosPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Dispositivos</h1>
      <p className="text-subtitulo text-tinta-suave">
        Si se pierde un celular de la caja, cierra aquí su sesión.
      </p>
      <Dispositivos />
    </>
  );
}
