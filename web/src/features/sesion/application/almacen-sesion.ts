import { comercioInicial, negociosDelPanel } from '../domain/reglas-ingreso';
import type {
  PreferenciasSesion,
  RepositorioSesion,
  ResultadoIngreso,
  SesionActiva,
} from '../domain/sesion';

export type EstadoSesion =
  | { fase: 'iniciando' }
  | { fase: 'sin-sesion' }
  | { fase: 'cambio-de-pin'; tokenCambio: string; nombre: string }
  | { fase: 'activa'; sesion: SesionActiva; comercioId: string | null };

/** Margen para renovar antes de que el token venza en plena petición. */
const MARGEN_MS = 30_000;

/**
 * Estado de la sesión del panel, fuera de React para poder probarlo solo. El token de
 * acceso vive en memoria; si dos peticiones lo encuentran vencido, se renueva una sola vez.
 */
export class AlmacenSesion {
  private actual: EstadoSesion = { fase: 'iniciando' };
  private readonly oyentes = new Set<() => void>();
  private renovando: Promise<string | null> | null = null;

  constructor(
    private readonly repositorio: RepositorioSesion,
    private readonly preferencias: PreferenciasSesion,
    private readonly ahora: () => number = Date.now,
  ) {}

  estado = (): EstadoSesion => this.actual;

  suscribir = (oyente: () => void): (() => void) => {
    this.oyentes.add(oyente);
    return () => this.oyentes.delete(oyente);
  };

  /** Al abrir el panel: recupera la sesión con la cookie de renovación, si existe. */
  async iniciar(): Promise<void> {
    if (this.actual.fase !== 'iniciando') return;
    await this.renovar();
  }

  async entrarConPin(celular: string, pin: string): Promise<void> {
    this.aplicarIngreso(await this.repositorio.entrarConPin(celular, pin));
  }

  async entrarConContrasena(correo: string, contrasena: string): Promise<void> {
    this.aplicarIngreso(await this.repositorio.entrarConContrasena(correo, contrasena));
  }

  async crearPinNuevo(pinNuevo: string): Promise<void> {
    if (this.actual.fase !== 'cambio-de-pin') return;
    this.abrir(await this.repositorio.crearPinNuevo(this.actual.tokenCambio, pinNuevo));
  }

  async elegirComercio(comercioId: string): Promise<void> {
    const token = await this.tokenVigente();
    if (!token || this.actual.fase !== 'activa') return;
    await this.repositorio.elegirComercio(token, comercioId);
    this.preferencias.guardarComercio(comercioId);
    this.cambiar({ ...this.actual, comercioId });
  }

  /**
   * Recién registrado un negocio (HU-03-01): trae otra vez la lista de negocios,
   * que ya lo incluye como propietario, y lo deja activo.
   */
  async estrenarNegocio(comercioId: string): Promise<void> {
    await this.renovar();
    await this.elegirComercio(comercioId);
  }

  /** Vuelve a la lista de negocios sin cerrar la sesión. */
  cambiarDeNegocio(): void {
    if (this.actual.fase !== 'activa') return;
    this.preferencias.guardarComercio(null);
    this.cambiar({ ...this.actual, comercioId: null });
  }

  /** Token listo para usar; lo renueva antes si está por vencer. null = hay que entrar de nuevo. */
  async tokenVigente(): Promise<string | null> {
    if (this.actual.fase !== 'activa') return null;
    const { tokenAcceso, venceEn } = this.actual.sesion;
    return venceEn - this.ahora() > MARGEN_MS ? tokenAcceso : this.renovar();
  }

  /** Renueva una sola vez aunque la pidan varias peticiones a la vez. */
  renovar(): Promise<string | null> {
    this.renovando ??= this.repositorio
      .renovar()
      .then((sesion) => {
        if (!sesion) return this.terminar();
        this.abrir(sesion);
        return sesion.tokenAcceso;
      })
      .catch(() => this.terminar())
      .finally(() => {
        this.renovando = null;
      });
    return this.renovando;
  }

  async salir(): Promise<void> {
    const token = this.actual.fase === 'activa' ? this.actual.sesion.tokenAcceso : null;
    await this.repositorio.salir(token).catch(() => undefined);
    this.preferencias.guardarComercio(null);
    this.terminar();
  }

  private aplicarIngreso(resultado: ResultadoIngreso): void {
    if (resultado.tipo === 'sesion') return this.abrir(resultado.sesion);
    const { tokenCambio, nombre } = resultado;
    this.cambiar({ fase: 'cambio-de-pin', tokenCambio, nombre });
  }

  private abrir(sesion: SesionActiva): void {
    const anterior = this.actual.fase === 'activa' ? this.actual.comercioId : null;
    const negocios = negociosDelPanel(sesion.espacios);
    const guardado = anterior ?? this.preferencias.comercioGuardado();
    this.cambiar({ fase: 'activa', sesion, comercioId: comercioInicial(negocios, guardado) });
  }

  private terminar(): null {
    this.cambiar({ fase: 'sin-sesion' });
    return null;
  }

  private cambiar(estado: EstadoSesion): void {
    this.actual = estado;
    this.oyentes.forEach((oyente) => oyente());
  }
}
