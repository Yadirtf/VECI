import { Injectable } from '@nestjs/common';
import { ClienteTransaccion } from './transaccion-comercio';
import { PrismaService } from './prisma.service';

/** Usuario y persona de la sesión, para leer lo propio antes de elegir comercio. */
export interface ContextoUsuario {
  readonly usuarioId: string;
  readonly personaId: string;
}

/**
 * Fija app.user_id y app.person_id (SET LOCAL): las políticas staff_self y
 * customer_self dejan ver solo las membresías, afiliaciones y comercios propios
 * (HU-02-03). Este contexto es de lectura; los cambios en un comercio se hacen
 * con TransaccionComercio.
 */
@Injectable()
export class TransaccionUsuario {
  constructor(private readonly prisma: PrismaService) {}

  ejecutarComo<T>(
    contexto: ContextoUsuario,
    trabajo: (tx: ClienteTransaccion) => Promise<T>,
  ): Promise<T> {
    return this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT set_config('app.user_id', ${contexto.usuarioId}, true),
                                  set_config('app.person_id', ${contexto.personaId}, true)`;
      return trabajo(tx);
    });
  }
}
