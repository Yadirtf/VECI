import { Boton } from './boton';

const INDICACION_TEMPORAL =
  'Díctaselo o anótaselo. Al entrar a VECI con su celular, creará su propio PIN. Por seguridad no lo volvemos a mostrar.';

export interface PinParaDictarProps {
  nombre: string;
  pin: string;
  alCerrar(): void;
  /** Qué PIN es: "PIN temporal" (equipo) o "PIN de bienvenida" (clientes). */
  titulo?: string;
  /** Qué hacer con el PIN, en una o dos frases. */
  indicacion?: string;
}

/** El PIN se ve una sola vez, grande, para dictarlo o anotarlo. */
export function PinParaDictar({
  nombre,
  pin,
  alCerrar,
  titulo = 'PIN temporal',
  indicacion = INDICACION_TEMPORAL,
}: PinParaDictarProps) {
  return (
    <section
      role="status"
      aria-label={titulo}
      className="rounded-l border-2 border-maiz bg-aviso-fondo p-l"
    >
      <p className="text-subtitulo font-medio text-tinta">
        {titulo} para {nombre}:
      </p>
      <p className="my-s font-mono text-grande font-fuerte tracking-[0.3em] text-tinta">{pin}</p>
      <p className="text-cuerpo text-tinta-suave">{indicacion}</p>
      <Boton variante="secundario" className="mt-m" onClick={alCerrar}>
        Ya lo anoté
      </Boton>
    </section>
  );
}
