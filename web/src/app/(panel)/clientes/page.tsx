import { Clientes } from '@/features/clientes';

export const metadata = { title: 'Clientes · VECI' };

export default function ClientesPage() {
  return (
    <>
      <h1 className="text-grande font-fuerte text-tinta">Tus clientes</h1>
      <Clientes />
    </>
  );
}
