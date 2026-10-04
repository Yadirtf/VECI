import { createHmac, timingSafeEqual } from 'node:crypto';
import {
  CargaToken,
  FirmadorTokens,
  TokenVerificado,
} from '../../application/puertos/firmador-tokens.port';
import { Reloj } from '../../application/puertos/reloj.port';

const CABECERA = codificar({ alg: 'HS256', typ: 'JWT' });

function codificar(valor: object): string {
  return Buffer.from(JSON.stringify(valor)).toString('base64url');
}

function leerCarga(parte: string): Record<string, unknown> | null {
  try {
    const valor: unknown = JSON.parse(Buffer.from(parte, 'base64url').toString('utf8'));
    return valor && typeof valor === 'object' ? (valor as Record<string, unknown>) : null;
  } catch {
    return null;
  }
}

/**
 * JWT HS256 sin dependencias: solo acepta la cabecera exacta que emite (nada de
 * alg "none" ni cambio de algoritmo) y compara firmas en tiempo constante.
 */
export class FirmadorHs256 implements FirmadorTokens {
  constructor(
    private readonly secreto: string,
    private readonly reloj: Reloj,
  ) {}

  firmar(carga: CargaToken, segundos: number): string {
    const iat = Math.floor(this.reloj.ahora().getTime() / 1000);
    const cuerpo = `${CABECERA}.${codificar({ ...carga, iat, exp: iat + segundos })}`;
    return `${cuerpo}.${this.firma(cuerpo)}`;
  }

  verificar(token: string): TokenVerificado {
    const partes = token.split('.');
    if (partes.length !== 3 || partes[0] !== CABECERA) return { estado: 'invalido' };
    const esperada = Buffer.from(this.firma(`${partes[0]}.${partes[1]}`));
    const recibida = Buffer.from(partes[2]);
    if (esperada.length !== recibida.length || !timingSafeEqual(esperada, recibida)) {
      return { estado: 'invalido' };
    }
    const carga = leerCarga(partes[1]);
    if (!carga || typeof carga.exp !== 'number') return { estado: 'invalido' };
    if (carga.exp * 1000 <= this.reloj.ahora().getTime()) return { estado: 'vencido' };
    return { estado: 'valido', carga: carga as CargaToken };
  }

  private firma(cuerpo: string): string {
    return createHmac('sha256', this.secreto).update(cuerpo).digest('base64url');
  }
}
