'use client';

import { Aviso } from './aviso';
import { Boton } from './boton';
import { Campo } from './campo';
import { Saldo } from './saldo';
import { Tarjeta } from './tarjeta';

const COLORES = ['selva', 'selva-oscuro', 'arcilla', 'maiz', 'crema', 'tinta', 'error', 'aviso'];

/** Página viva del sistema de diseño VECI (HU-01-09), para revisar al sol y en el celular. */
export function MuestrarioDisenio() {
  return (
    <>
      <h1 className="text-grande font-fuerte">Sistema de diseño VECI</h1>
      <Tarjeta aria-label="Colores">
        <h2 className="mb-m text-titulo font-fuerte">Colores</h2>
        <ul className="grid grid-cols-2 gap-s sm:grid-cols-4">
          {COLORES.map((color) => (
            <li key={color} className="flex items-center gap-s text-pequeno">
              <span
                className="size-10 rounded-s border border-borde"
                style={{ background: `var(--color-${color})` }}
              />
              {color}
            </li>
          ))}
        </ul>
      </Tarjeta>
      <Tarjeta aria-label="Botones y campos" className="flex flex-col gap-m">
        <Boton grande>Cobrar con QR</Boton>
        <Boton>Vender tiquetera</Boton>
        <Boton variante="secundario">Buscar cliente</Boton>
        <Boton variante="peligro">Anular venta</Boton>
        <Campo
          etiqueta="Celular del cliente"
          placeholder="310 000 0000"
          ayuda="Lo usamos para avisarle su saldo."
        />
      </Tarjeta>
      <Tarjeta aria-label="Mensajes" className="flex flex-col gap-m">
        <Saldo unidades={12} singular="almuerzo" plural="almuerzos" />
        <Aviso tono="exito">¡Listo, veci! Te quedan 12 almuerzos.</Aviso>
        <Aviso tono="aviso">¡Ojo, veci! A Luz Marina le quedan 2 almuerzos.</Aviso>
        <Aviso tono="error">Este QR es de otro negocio. Pídele al cliente el QR de aquí.</Aviso>
      </Tarjeta>
    </>
  );
}
