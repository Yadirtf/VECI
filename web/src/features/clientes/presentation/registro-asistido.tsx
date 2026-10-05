'use client';

import Link from 'next/link';
import { Aviso, Boton, Tarjeta } from '@/shared/ui';
import { useRegistroAsistido } from '../application/use-registro-asistido';
import type {
  PersonaEncontrada,
  Politica,
  RepositorioClientes,
  ResultadoRegistro,
} from '../domain/cliente';
import { datoInicial } from '../domain/reglas-clientes';
import { FormularioPersonaNueva, PasoDocumento } from './pasos-registro';
import { PoliticaEnCorto } from './politica-en-corto';

export interface RegistroAsistidoProps {
  repositorio: RepositorioClientes;
  /** Lo que estaba escrito en el buscador: sirve de documento o de nombre. */
  desde: string;
  alRegistrar(resultado: ResultadoRegistro): void;
  alVerFicha(clienteId: string): void;
}

type Registro = ReturnType<typeof useRegistroAsistido>;

function LeerPolitica({ politica }: { politica: Politica }) {
  return (
    <div className="flex flex-col gap-s">
      <PoliticaEnCorto enCorto={politica.enCorto} titulo="Léele esto en voz alta" />
      <Link
        href="/politica-de-datos"
        target="_blank"
        className="self-start text-cuerpo text-selva-oscuro underline"
      >
        Leer la política completa
      </Link>
    </div>
  );
}

function PersonaYaEnVeci(
  p: { persona: PersonaEncontrada; r: Registro; politica: Politica } & Pick<
    RegistroAsistidoProps,
    'alVerFicha'
  >,
) {
  const { persona, r } = p;
  const quien = (
    <p className="text-subtitulo">
      <strong>{persona.nombre}</strong> · Documento {persona.documento}
    </p>
  );
  if (persona.clienteId) {
    const clienteId = persona.clienteId;
    return (
      <div className="flex flex-col gap-m">
        {quien}
        <Aviso tono="exito">Ya es cliente de tu negocio.</Aviso>
        <Boton variante="secundario" className="self-start" onClick={() => p.alVerFicha(clienteId)}>
          Ver su ficha
        </Boton>
      </div>
    );
  }
  return (
    <div className="flex flex-col gap-m">
      <p className="text-cuerpo">Ya está en VECI. ¿Es esta persona?</p>
      {quien}
      <LeerPolitica politica={p.politica} />
      <Boton disabled={r.ocupado} className="self-start" onClick={() => void r.registrar(null)}>
        {r.ocupado ? 'Afiliando…' : 'Afiliar a esta persona'}
      </Boton>
      {r.problema && <Aviso tono="error">{r.problema}</Aviso>}
    </div>
  );
}

function Pasos({
  r,
  desde,
  alVerFicha,
}: { r: Registro } & Omit<RegistroAsistidoProps, 'repositorio' | 'alRegistrar'>) {
  if (r.catalogos.tipo === 'cargando') return <Aviso tono="aviso">Un momento, veci…</Aviso>;
  if (r.catalogos.tipo === 'error') return <Aviso tono="error">{r.catalogos.mensaje}</Aviso>;
  const { politica, tipos } = r.catalogos.datos;
  const inicial = datoInicial(desde);
  if (r.paso.tipo === 'encontrada') {
    return (
      <PersonaYaEnVeci persona={r.paso.persona} r={r} politica={politica} alVerFicha={alVerFicha} />
    );
  }
  if (r.paso.tipo === 'nueva') {
    return (
      <div className="flex flex-col gap-m">
        <p className="text-cuerpo">Es nueva en VECI. Anota sus datos.</p>
        <FormularioPersonaNueva
          nombresIniciales={inicial.nombres}
          ocupado={r.ocupado}
          celularEnUso={r.celularEnUso}
          problema={r.problema}
          politica={<LeerPolitica politica={politica} />}
          alRegistrar={(datos, compartido) => void r.registrar(datos, compartido)}
        />
      </div>
    );
  }
  return (
    <>
      <PasoDocumento
        tipos={tipos}
        numeroInicial={r.documento?.numeroDocumento ?? inicial.numeroDocumento}
        tipoInicial={r.documento?.tipoDocumento}
        ocupado={r.ocupado}
        alRevisar={(doc) => void r.revisar(doc)}
      />
      {r.problema && <Aviso tono="error">{r.problema}</Aviso>}
    </>
  );
}

/** Registrar un cliente en un solo panel: documento, sus datos o afiliarlo, y la política. */
export function RegistroAsistido({
  repositorio,
  desde,
  alRegistrar,
  alVerFicha,
}: RegistroAsistidoProps) {
  const r = useRegistroAsistido(repositorio, alRegistrar);
  return (
    <Tarjeta aria-label="Registrar cliente" className="flex flex-col gap-m">
      <h2 className="text-titulo font-fuerte text-tinta">Registrar cliente</h2>
      {r.documento && r.paso.tipo !== 'documento' && (
        <p className="flex flex-wrap items-center gap-s text-cuerpo text-tinta-suave">
          {r.documento.tipoDocumento} {r.documento.numeroDocumento}
          <button type="button" className="underline" onClick={r.cambiarDocumento}>
            Cambiar documento
          </button>
        </p>
      )}
      <Pasos r={r} desde={desde} alVerFicha={alVerFicha} />
    </Tarjeta>
  );
}
