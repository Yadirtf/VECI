import { EntradaAuditoria } from '../../../../shared/application/puertos/auditoria.port';
import {
  CargaToken,
  TokenVerificado,
} from '../../../../shared/application/puertos/firmador-tokens.port';
import { Credencial, TipoCredencial } from '../../domain/entities/credencial.entity';
import { Cuenta } from '../../domain/entities/cuenta';
import { RolEnComercio } from '../../domain/entities/espacio';
import { NuevaCredencial } from '../puertos/credenciales.repository';
import { TipoIdentificador } from '../puertos/cuentas.repository';
import { IntentoIngreso } from '../puertos/intentos-ingreso.port';
import {
  Dispositivo,
  MotivoCierre,
  NuevaSesion,
  SesionGuardada,
} from '../puertos/sesiones.repository';
import { ComprobadorCredencial } from '../servicios/comprobador-credencial';
import { EmisorSesion } from '../servicios/emisor-sesion';
import { ConsultarEspacios } from './consultar-espacios.use-case';

/** Base de datos en memoria para probar la autenticación sin PostgreSQL. */
export class AutenticacionEnMemoria {
  ahora = new Date('2026-10-05T12:00:00Z');
  readonly cuentas = new Map<string, Cuenta>();
  readonly identificadores = new Map<string, string>();
  readonly credenciales: Array<{ credencial: Credencial; revocada: boolean; motivo?: string }> = [];
  readonly sesiones = new Map<string, SesionGuardada & { motivo?: MotivoCierre }>();
  readonly dispositivos: Dispositivo[] = [];
  readonly intentos: IntentoIngreso[] = [];
  readonly auditoria: EntradaAuditoria[] = [];
  readonly roles: RolEnComercio[] = [];
  readonly aceptadas: string[] = [];
  private contador = 0;

  id = (): string => `id-${++this.contador}`;

  agregarCuenta(cuenta: Cuenta, celular: string, pin: string, debeCambiar = false): void {
    this.cuentas.set(cuenta.usuarioId, cuenta);
    this.identificadores.set(`MOBILE_PHONE:${celular}`, cuenta.usuarioId);
    this.crearCredencial(cuenta.usuarioId, 'PIN', `hash:${pin}`, debeCambiar);
  }

  crearCredencial(
    usuarioId: string,
    tipo: TipoCredencial,
    hash: string,
    debeCambiar: boolean,
  ): string {
    const id = this.id();
    const reglas = { maxIntentos: 5, minutosBloqueo: 15, horasTemporal: 168 };
    const datos = {
      id,
      usuarioId,
      tipo,
      hash,
      debeCambiar,
      intentosFallidos: 0,
      bloqueadaHasta: null,
      reglas,
      emitidaEn: this.ahora,
    };
    this.credenciales.push({ credencial: Credencial.desde(datos), revocada: false });
    return id;
  }

  vigente(usuarioId: string, tipo: TipoCredencial): Credencial | null {
    const fila = this.credenciales.find(
      (c) => !c.revocada && c.credencial.usuarioId === usuarioId && c.credencial.tipo === tipo,
    );
    return fila?.credencial ?? null;
  }

  readonly repoCuentas = {
    buscarPorIdentificador: async (tipo: TipoIdentificador, valor: string) =>
      this.cuentas.get(this.identificadores.get(`${tipo}:${valor}`) ?? '') ?? null,
    buscarPorId: async (usuarioId: string) => this.cuentas.get(usuarioId) ?? null,
    activar: async (usuarioId: string) => {
      const cuenta = this.cuentas.get(usuarioId);
      if (cuenta)
        this.cuentas.set(usuarioId, { ...cuenta, puedeEntrar: true, pendienteDeActivar: false });
    },
    registrarIngreso: async () => undefined,
    asignarCorreo: async (usuarioId: string, correo: string) => {
      this.identificadores.set(`EMAIL:${correo}`, usuarioId);
    },
  };

  readonly repoCredenciales = {
    vigente: async (usuarioId: string, tipo: TipoCredencial) => this.vigente(usuarioId, tipo),
    guardarIntentos: async () => undefined,
    reemplazar: async (nueva: NuevaCredencial) => {
      for (const fila of this.credenciales) {
        const misma =
          fila.credencial.usuarioId === nueva.usuarioId && fila.credencial.tipo === nueva.tipo;
        if (misma && !fila.revocada) Object.assign(fila, { revocada: true, motivo: nueva.motivo });
      }
      return this.crearCredencial(nueva.usuarioId, nueva.tipo, nueva.hash, nueva.debeCambiar);
    },
  };

  readonly repoSesiones = {
    registrarDispositivo: async (d: Dispositivo) => void this.dispositivos.push(d),
    crear: async (s: NuevaSesion) => void this.sesiones.set(s.id, { ...s, cerrada: false }),
    buscar: async (id: string) => this.sesiones.get(id) ?? null,
    rotar: async (id: string, anterior: string, nueva: string, expiraEn: Date) => {
      const sesion = this.sesiones.get(id);
      if (!sesion || sesion.cerrada || sesion.huella !== anterior) return false;
      this.sesiones.set(id, { ...sesion, huella: nueva, expiraEn });
      return true;
    },
    cerrar: async (id: string, motivo: MotivoCierre) => {
      const sesion = this.sesiones.get(id);
      if (sesion) this.sesiones.set(id, { ...sesion, cerrada: true, motivo });
    },
    cerrarTodasDe: async (usuarioId: string, motivo: MotivoCierre) => {
      const abiertas = [...this.sesiones.values()].filter(
        (s) => s.usuarioId === usuarioId && !s.cerrada,
      );
      abiertas.forEach((s) => this.sesiones.set(s.id, { ...s, cerrada: true, motivo }));
      return abiertas.length;
    },
  };

  readonly repoEspacios = {
    listar: async (usuarioId: string) =>
      this.roles.filter((r) => r.comercioId.startsWith(usuarioId)),
    aceptarInvitacion: async (usuarioId: string, comercioId: string) =>
      void this.aceptadas.push(`${usuarioId}@${comercioId}`),
    registrarDispositivoEnComercio: async () => undefined,
  };

  readonly cifrador = {
    cifrar: async (secreto: string) => `hash:${secreto}`,
    coincide: async (hash: string, secreto: string) => hash === `hash:${secreto}`,
  };

  readonly secretos = {
    token: () => `secreto-${++this.contador}`,
    digitos: () => '730284',
    huella: (valor: string) => `h(${valor})`,
  };

  /** Firmador de mentira: la carga va en claro, con vencimiento. */
  readonly firmador = {
    firmar: (carga: CargaToken, segundos: number) =>
      JSON.stringify({ ...carga, exp: this.ahora.getTime() + segundos * 1000 }),
    verificar: (token: string): TokenVerificado => {
      try {
        const carga = JSON.parse(token) as CargaToken & { exp: number };
        if (carga.exp <= this.ahora.getTime()) return { estado: 'vencido' };
        return { estado: 'valido', carga };
      } catch {
        return { estado: 'invalido' };
      }
    },
  };

  readonly reloj = { ahora: () => this.ahora };
  readonly intentosIngreso = { registrar: async (i: IntentoIngreso) => void this.intentos.push(i) };
  readonly bitacora = { registrar: async (e: EntradaAuditoria) => void this.auditoria.push(e) };

  piezas() {
    const espacios = new ConsultarEspacios(this.repoEspacios, this.repoCuentas);
    const emisor = new EmisorSesion({
      sesiones: this.repoSesiones,
      cuentas: this.repoCuentas,
      espacios,
      firmador: this.firmador,
      secretos: this.secretos,
      ids: { siguiente: this.id },
      reloj: this.reloj,
      reglas: { segundosAcceso: 900, diasSesion: 30 },
    });
    const comprobador = new ComprobadorCredencial({
      credenciales: this.repoCredenciales,
      cifrador: this.cifrador,
      intentos: this.intentosIngreso,
      auditoria: this.bitacora,
      reloj: this.reloj,
    });
    const base = {
      cuentas: this.repoCuentas,
      credenciales: this.repoCredenciales,
      sesiones: this.repoSesiones,
      cifrador: this.cifrador,
      secretos: this.secretos,
    };
    return { base, espacios, emisor, comprobador };
  }
}
