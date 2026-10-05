'use client';

import { useState } from 'react';
import { Aviso } from './aviso';
import { Boton } from './boton';
import { Campo } from './campo';
import { Saldo } from './saldo';
import { Sello } from './sello';
import { Tarjeta } from './tarjeta';

const COLORES = ['selva', 'selva-oscuro', 'arcilla', 'maiz', 'crema', 'tinta', 'error', 'aviso'];
const TOTAL = 20;

/** Página viva del sistema de diseño VECI (HU-01-09), para revisar al sol y en el celular. */
export function MuestrarioDisenio() {
  return (
    <>
      <h1 className="text-grande font-fuerte">Sistema de diseño VECI</h1>
      <Tarjeta perforado aria-label="Cómo se lee">
        <p className="text-subtitulo">
          La forma dice qué es: <strong>papelito</strong> = VECI te habla, <strong>piedra</strong> =
          lo que tú haces, <strong>esquinas cortadas</strong> = cuidado, no se deshace,{' '}
          <strong>colilla</strong> = saldo, <strong>arco</strong> = dónde estás.
        </p>
      </Tarjeta>
      <SaldoVivo />
      <Tarjeta aria-label="Colores">
        <h2 className="mb-m text-titulo font-fuerte">Colores</h2>
        <ul className="grid grid-cols-2 gap-s sm:grid-cols-4">
          {COLORES.map((color) => (
            <li key={color} className="flex items-center gap-s text-pequeno">
              <span
                className="piedra size-10 border border-borde"
                style={{ background: `var(--color-${color})` }}
              />
              {color}
            </li>
          ))}
        </ul>
      </Tarjeta>
      <Tarjeta aria-label="Botones y campos" className="flex flex-col gap-m">
        <Boton>Vender tiquetera</Boton>
        <Boton variante="secundario">Buscar cliente</Boton>
        <Boton variante="peligro">Anular venta</Boton>
        <Campo
          etiqueta="Celular del cliente"
          placeholder="310 000 0000"
          ayuda="Lo usamos para avisarle su saldo."
        />
      </Tarjeta>
      <div aria-label="Mensajes" className="flex flex-col gap-m">
        <Aviso tono="exito">¡Listo, veci! Te quedan 12 almuerzos.</Aviso>
        <Aviso tono="aviso">¡Ojo, veci! A Luz Marina le quedan 2 almuerzos.</Aviso>
        <Aviso tono="error">Este QR es de otro negocio. Pídele al cliente el QR de aquí.</Aviso>
      </div>
    </>
  );
}

/** Toque «Registrar almuerzo»: la colilla pierde una casilla y cae el sello. */
function SaldoVivo() {
  const [consumos, setConsumos] = useState(8);
  const quedan = TOTAL - consumos;
  return (
    <Tarjeta aria-label="Saldo y sello" className="flex flex-col items-start gap-l">
      <Saldo unidades={quedan} singular="almuerzo" plural="almuerzos" total={TOTAL} />
      {consumos > 8 && (
        <Sello
          key={consumos}
          arriba="¡Listo, veci!"
          cifra={String(quedan)}
          abajo={quedan === 1 ? 'almuerzo' : 'almuerzos'}
          semilla={`consumo-${consumos}`}
        />
      )}
      <Boton grande disabled={quedan === 0} onClick={() => setConsumos(consumos + 1)}>
        Registrar almuerzo
      </Boton>
    </Tarjeta>
  );
}
