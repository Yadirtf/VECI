import { UnauthorizedException } from '@nestjs/common';
import type { Request } from 'express';
import { Identidad } from '../../application/contexto/identidad';
import { ResolvedorIdentidad } from '../../application/contexto/resolvedor-identidad.port';

/** Petición con la identidad que dejó un guard. */
export type PeticionAutenticada = Request & { veciIdentidad?: Identidad; veciComercioId?: string };

/** Resuelve la identidad, la deja en la petición y exige que exista. */
export async function autenticar(
  peticion: PeticionAutenticada,
  resolvedor: ResolvedorIdentidad,
): Promise<Identidad> {
  const identidad = await resolvedor.resolver(peticion.headers);
  if (!identidad) throw new UnauthorizedException('Primero inicia sesión, veci.');
  peticion.veciIdentidad = identidad;
  return identidad;
}
