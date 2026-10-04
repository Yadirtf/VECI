import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma/prisma.service';
import { IntentoIngreso, IntentosIngreso } from '../../application/puertos/intentos-ingreso.port';

/** identity.login_attempts: solo inserción, particionada por mes. */
@Injectable()
export class PrismaIntentosIngreso implements IntentosIngreso {
  constructor(private readonly prisma: PrismaService) {}

  async registrar(intento: IntentoIngreso): Promise<void> {
    await this.prisma.$executeRaw`
      INSERT INTO identity.login_attempts
             (identifier_hash, user_id, device_id, ip_address, succeeded, login_failure_reason_id)
      VALUES (decode(${intento.huellaIdentificador}, 'hex'), ${intento.usuarioId}::uuid,
              ${intento.dispositivoId}::uuid, ${intento.ip}::inet, ${intento.motivoFallo === null},
              (SELECT id FROM identity.login_failure_reasons WHERE code = ${intento.motivoFallo}))`;
  }
}
