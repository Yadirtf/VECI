import Link from 'next/link';
import { Tarjeta } from '@/shared/ui';

export default function InicioPage() {
  return (
    <Tarjeta>
      <h1 className="text-grande font-fuerte text-selva-oscuro">¡Hola, veci!</h1>
      <p className="mt-s text-subtitulo text-tinta-suave">
        Aquí vas a ver tus ventas, tus clientes y el dinero de tus tiqueteras.
      </p>
      <Link
        href="/horarios"
        className="mt-l inline-flex min-h-toque-boton items-center rounded-m bg-selva px-l text-subtitulo font-medio text-superficie hover:bg-selva-oscuro"
      >
        Ver mis horarios
      </Link>
    </Tarjeta>
  );
}
