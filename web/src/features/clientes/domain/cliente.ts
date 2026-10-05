/** ACTIVA: usa la app. PENDIENTE: espera su PIN de bienvenida. SIN_CUENTA: no tiene app propia. */
export type CuentaCliente = 'ACTIVA' | 'PENDIENTE' | 'SIN_CUENTA';
export type EstadoCliente = 'ACTIVE' | 'BLOCKED' | 'ENDED';
export type CanalCliente = 'PERSONAL_QR_SCAN' | 'ASSISTED_REGISTRATION' | 'DATA_IMPORT';

/** Un renglón de la libreta: siempre con documento y celular tapados. */
export interface ClienteEnLibreta {
  clienteId: string;
  nombre: string;
  /** Sin tildes ni mayúsculas, para buscar. */
  nombreBusqueda: string;
  /** ****5678 */
  documento: string;
  documentoFinal: string;
  /** ••• 8888 */
  celular: string | null;
  celularFinal: string | null;
  cuenta: CuentaCliente;
  estado: EstadoCliente;
}

/** Ficha del cliente en el negocio. El dueño recibe documento y celular completos. */
export interface FichaCliente {
  clienteId: string;
  personaId: string;
  nombre: string;
  nombres: string;
  apellidos: string | null;
  tipoDocumento: string;
  documento: string;
  celular: string | null;
  datosCompletos: boolean;
  cuenta: CuentaCliente;
  estado: EstadoCliente;
  canal: CanalCliente;
  afiliadoEn: Date;
}

export interface DocumentoPersona {
  tipoDocumento: string;
  numeroDocumento: string;
}

/** Persona que ya está en VECI: nombre y documento tapados ("Luz Marina C.", "****5678"). */
export interface PersonaEncontrada {
  personaId: string;
  nombre: string;
  documento: string;
  /** Si ya es cliente de este negocio. */
  clienteId: string | null;
}

export interface DatosPersonaNueva {
  nombres: string;
  apellidos?: string;
  celular: string;
}

export interface DatosRegistroAsistido extends DocumentoPersona, Partial<DatosPersonaNueva> {
  /** El celular es de otra persona de la familia: queda solo de contacto. */
  celularCompartido: boolean;
  /** Versión de la política que se le leyó y aceptó. */
  politicaVersionId: string;
}

export interface ResultadoRegistro {
  /** Ya estaba en VECI y solo se afilió. */
  vinculado: boolean;
  cliente: FichaCliente;
  /** Se muestra una sola vez para dictarlo. Sirve 7 días. */
  pinBienvenida: string | null;
}

export interface TipoDocumento {
  codigo: string;
  nombre: string;
  /** Expresión que debe cumplir el número, si el tipo la tiene. */
  patron: string | null;
}

export interface SeccionPolitica {
  titulo: string;
  enPalabrasDeVecino: string;
  texto: string;
}

/** Política de datos vigente: el "en corto" para leer en voz alta y el texto completo. */
export interface Politica {
  id: string;
  version: string;
  publicadaEn: Date;
  enCorto: { anotamos: readonly string[]; nuncaHacemos: readonly string[]; paraQue: string };
  secciones: readonly SeccionPolitica[];
}

/** Lo que la API dijo que salió mal; el código es para el programa, el mensaje para la pantalla. */
export class ProblemaClientes extends Error {
  constructor(
    readonly codigo: string,
    mensaje: string,
  ) {
    super(mensaje);
    this.name = 'ProblemaClientes';
  }
}

/** La política de datos se lee sin sesión. */
export interface FuentePolitica {
  politica(): Promise<Politica>;
}

/** Clientes del negocio activo; la infraestructura decide de dónde salen. */
export interface RepositorioClientes extends FuentePolitica {
  libreta(): Promise<ClienteEnLibreta[]>;
  /** Busca en el servidor (documento o celular completos); desde 3 letras o números. */
  buscar(texto: string): Promise<ClienteEnLibreta[]>;
  ficha(clienteId: string): Promise<FichaCliente>;
  darPinBienvenida(clienteId: string): Promise<string>;
  tiposDocumento(): Promise<TipoDocumento[]>;
  revisar(documento: DocumentoPersona): Promise<PersonaEncontrada | null>;
  registrar(datos: DatosRegistroAsistido): Promise<ResultadoRegistro>;
}
