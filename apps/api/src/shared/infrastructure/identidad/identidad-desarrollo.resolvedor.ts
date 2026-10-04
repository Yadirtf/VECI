import { CABECERA_USUARIO_DESARROLLO } from '@veci/shared';
import {
  Cabeceras,
  ResolvedorIdentidad,
} from '../../application/contexto/resolvedor-identidad.port';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Identidad provisional mientras llega el inicio de sesión con celular y PIN (EP-02):
 * toma el usuario de la cabecera x-veci-usuario. Desactivada en producción, donde
 * ninguna petición queda autenticada hasta que EP-02 reemplace esta clase.
 */
export class IdentidadDesarrolloResolvedor implements ResolvedorIdentidad {
  constructor(private readonly activa: boolean) {}

  resolver(cabeceras: Cabeceras): Promise<string | null> {
    const valor = cabeceras[CABECERA_USUARIO_DESARROLLO];
    if (!this.activa || typeof valor !== 'string' || !UUID.test(valor)) {
      return Promise.resolve(null);
    }
    return Promise.resolve(valor.toLowerCase());
  }
}
