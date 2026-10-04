import type { ClienteVeci } from '@/shared/api/cliente';
import { leerProblema } from '@/shared/api/problema';
import type { RepositorioCuenta } from '../domain/cuenta';

const falla = (error: unknown) => new Error(leerProblema(error).mensaje);

export class RepositorioCuentaApi implements RepositorioCuenta {
  constructor(private readonly cliente: ClienteVeci) {}

  async cambiarPin(pinActual: string, pinNuevo: string): Promise<void> {
    const { error } = await this.cliente.PUT('/cuenta/pin', { body: { pinActual, pinNuevo } });
    if (error) throw falla(error);
  }

  async definirCorreo(correo: string, contrasena: string, pinActual: string): Promise<string> {
    const { data, error } = await this.cliente.PUT('/cuenta/correo-y-contrasena', {
      body: { correo: correo.trim(), contrasena, pinActual },
    });
    if (!data) throw falla(error);
    return data.correo;
  }
}
