import Link from 'next/link';
import { clasesBoton, Tarjeta } from '@/shared/ui';

export default function InicioPage() {
  return (
    <Tarjeta perforado className="flex flex-col items-start gap-m">
      <h1 className="text-grande font-fuerte text-selva-oscuro">¡Hola, veci!</h1>
      <p className="text-subtitulo text-tinta-suave">
        Aquí vas a ver tus ventas, tus clientes y el dinero de tus tiqueteras.
      </p>
      <Link href="/horarios" className={clasesBoton()}>
        Ver mis horarios
      </Link>
    </Tarjeta>
  );
}
