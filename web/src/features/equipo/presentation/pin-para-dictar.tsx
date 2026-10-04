import { Boton } from '@/shared/ui';

export interface PinParaDictarProps {
  nombre: string;
  pin: string;
  alCerrar(): void;
}

/** El PIN temporal se ve una sola vez, grande, para dictarlo o anotarlo. */
export function PinParaDictar({ nombre, pin, alCerrar }: PinParaDictarProps) {
  return (
    <section
      role="status"
      aria-label="PIN temporal"
      className="rounded-l border-2 border-maiz bg-aviso-fondo p-l"
    >
      <p className="text-subtitulo font-medio text-tinta">PIN temporal para {nombre}:</p>
      <p className="my-s font-mono text-grande font-fuerte tracking-[0.3em] text-tinta">{pin}</p>
      <p className="text-cuerpo text-tinta-suave">
        Díctaselo o anótaselo. Al entrar a VECI con su celular, creará su propio PIN. Por seguridad
        no lo volvemos a mostrar.
      </p>
      <Boton variante="secundario" className="mt-m" onClick={alCerrar}>
        Ya lo anoté
      </Boton>
    </section>
  );
}
