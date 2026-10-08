'use client';

import { useState } from 'react';
import { useAccion } from '@/shared/lib/use-accion';
import { Aviso, Boton, Campo, Tarjeta } from '@/shared/ui';
import { documentoLegible, problemaConMotivo, type SolicitudPorRevisar } from '../domain/solicitud';

interface Props {
  solicitud: SolicitudPorRevisar;
  alAprobar(): Promise<void>;
  alRechazar(motivo: string): Promise<void>;
}

const fecha = new Intl.DateTimeFormat('es-CO', { dateStyle: 'medium', timeStyle: 'short' });

/** Lo que hace falta para decidir: el negocio, dónde queda y quién lo pide. */
function DatosSolicitud({ s }: { s: SolicitudPorRevisar }) {
  return (
    <dl className="grid grid-cols-1 gap-x-m gap-y-xs text-cuerpo sm:grid-cols-[auto_1fr]">
      <dt className="font-medio">Tipo</dt>
      <dd>{s.tipoNegocio}</dd>
      <dt className="font-medio">Documento</dt>
      <dd>{documentoLegible(s.tipoDocumento, s.numeroDocumento)}</dd>
      <dt className="font-medio">Dónde</dt>
      <dd>{[s.direccion, s.municipio].filter(Boolean).join(', ')}</dd>
      <dt className="font-medio">Contacto</dt>
      <dd className="break-words">{[s.celular, s.correo].filter(Boolean).join(' · ')}</dd>
      <dt className="font-medio">Lo pide</dt>
      <dd>{[s.solicitante.nombre, s.solicitante.celular].filter(Boolean).join(' · ')}</dd>
      <dt className="font-medio">Llegó</dt>
      <dd>{fecha.format(s.radicadaEn)}</dd>
    </dl>
  );
}

/** Una solicitud con sus datos y las dos decisiones; rechazar pide decir por qué. */
export function TarjetaSolicitud({ solicitud: s, alAprobar, alRechazar }: Props) {
  const { ocupado, problema, setProblema, ejecutar } = useAccion();
  const [rechazando, setRechazando] = useState(false);
  const [motivo, setMotivo] = useState('');

  const rechazar = () => {
    const falta = problemaConMotivo(motivo);
    if (falta) return setProblema(falta);
    void ejecutar(() => alRechazar(motivo.trim()));
  };

  return (
    <Tarjeta>
      <article aria-label={s.nombre} className="flex flex-col gap-s">
        <h2 className="text-titulo font-fuerte text-tinta">{s.nombre}</h2>
        <DatosSolicitud s={s} />
        {rechazando && (
          <Campo
            etiqueta="¿Por qué no se aprueba?"
            ayuda="La persona lo lee tal cual en su app."
            value={motivo}
            onChange={(e) => setMotivo(e.target.value)}
          />
        )}
        {problema && <Aviso tono="aviso">{problema}</Aviso>}
        <div className="flex flex-wrap gap-s">
          {rechazando ? (
            <>
              <Boton variante="peligro" disabled={ocupado} onClick={rechazar}>
                Rechazar con este motivo
              </Boton>
              <Boton variante="secundario" disabled={ocupado} onClick={() => setRechazando(false)}>
                Cancelar
              </Boton>
            </>
          ) : (
            <>
              <Boton disabled={ocupado} onClick={() => void ejecutar(alAprobar)}>
                Aprobar y crear el negocio
              </Boton>
              <Boton variante="secundario" disabled={ocupado} onClick={() => setRechazando(true)}>
                Rechazar
              </Boton>
            </>
          )}
        </div>
      </article>
    </Tarjeta>
  );
}
