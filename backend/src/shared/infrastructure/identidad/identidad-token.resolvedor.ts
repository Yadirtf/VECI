import { Identidad } from '../../application/contexto/identidad';
import {
  Cabeceras,
  ResolvedorIdentidad,
} from '../../application/contexto/resolvedor-identidad.port';
import { VerificadorSesion } from '../../application/contexto/verificador-sesion.port';
import { CargaToken, FirmadorTokens } from '../../application/puertos/firmador-tokens.port';
import { SesionNoValida } from '../../domain/errores/sesion-no-valida.error';

/** Tipo de los tokens de acceso que emite el módulo de autenticación. */
export const TIPO_TOKEN_ACCESO = 'acceso';

function leerBearer(cabeceras: Cabeceras): string | null {
  const valor = cabeceras.authorization;
  if (typeof valor !== 'string') return null;
  const [esquema, token] = valor.split(' ');
  return esquema?.toLowerCase() === 'bearer' && token ? token : null;
}

function identidadDe(carga: CargaToken): Identidad | null {
  const { typ, sub, sid, dev } = carga;
  if (typ !== TIPO_TOKEN_ACCESO || typeof sub !== 'string' || typeof sid !== 'string') {
    return null;
  }
  return { usuarioId: sub, sesionId: sid, dispositivoId: typeof dev === 'string' ? dev : null };
}

/**
 * Identidad desde el token de acceso (HU-02-01). Además de la firma, revisa que la
 * sesión siga abierta: un cierre remoto corta el acceso en la siguiente petición
 * (HU-02-06). Sin token, delega en la identidad de desarrollo si existe.
 */
export class IdentidadTokenResolvedor implements ResolvedorIdentidad {
  constructor(
    private readonly firmador: FirmadorTokens,
    private readonly sesiones: VerificadorSesion,
    private readonly respaldo: ResolvedorIdentidad | null,
  ) {}

  async resolver(cabeceras: Cabeceras): Promise<Identidad | null> {
    const token = leerBearer(cabeceras);
    if (!token) return this.respaldo ? this.respaldo.resolver(cabeceras) : null;
    const verificado = this.firmador.verificar(token);
    if (verificado.estado === 'vencido') throw new SesionNoValida('TOKEN_VENCIDO');
    const identidad = verificado.estado === 'valido' ? identidadDe(verificado.carga) : null;
    if (!identidad?.sesionId) return null;
    const estado = await this.sesiones.estado(identidad.sesionId, identidad.usuarioId);
    if (estado === 'cerrada') throw new SesionNoValida('SESION_CERRADA');
    if (estado === 'vencida') throw new SesionNoValida('SESION_VENCIDA');
    return identidad;
  }
}
