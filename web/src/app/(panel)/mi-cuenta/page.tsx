import { MiCuenta } from '@/features/cuenta';

export const metadata = { title: 'Mi cuenta · VECI' };

export default function MiCuentaPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Mi cuenta</h1>
      <MiCuenta />
    </>
  );
}
