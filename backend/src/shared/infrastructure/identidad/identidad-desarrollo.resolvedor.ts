import { CABECERA_USUARIO_DESARROLLO } from '../../application/contexto/cabeceras';
import { Identidad } from '../../application/contexto/identidad';
import {
  Cabeceras,
  ResolvedorIdentidad,
} from '../../application/contexto/resolvedor-identidad.port';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Identidad para desarrollo local y pruebas automáticas: toma el usuario de la
 * cabecera x-veci-usuario cuando la petición no trae token. Desde EP-02 solo se
 * activa en los entornos desarrollo y pruebas, nunca en staging ni producción.
 */
export class IdentidadDesarrolloResolvedor implements ResolvedorIdentidad {
  constructor(private readonly activa: boolean) {}

  resolver(cabeceras: Cabeceras): Promise<Identidad | null> {
    const valor = cabeceras[CABECERA_USUARIO_DESARROLLO];
    if (!this.activa || typeof valor !== 'string' || !UUID.test(valor)) {
      return Promise.resolve(null);
    }
    return Promise.resolve({ usuarioId: valor.toLowerCase(), sesionId: null, dispositivoId: null });
  }
}
