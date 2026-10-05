import { Module } from '@nestjs/common';
import { AutenticacionModule } from '../autenticacion';
import { CLIENTES_REPOSITORY } from './application/puertos/clientes.repository';
import { MI_QR_REPOSITORY } from './application/puertos/mi-qr.repository';
import { POLITICA_REPOSITORY } from './application/puertos/politica.repository';
import { REGISTRO_REPOSITORY } from './application/puertos/registro.repository';
import { PROVEEDORES_CLIENTES } from './clientes.proveedores';
import { PrismaClientesRepository } from './infrastructure/persistence/prisma-clientes.repository';
import { PrismaMiQrRepository } from './infrastructure/persistence/prisma-mi-qr.repository';
import { PrismaRegistroRepository } from './infrastructure/persistence/prisma-registro.repository';
import { PrismaPoliticaRepository } from './infrastructure/politica/prisma-politica.repository';
import { AfiliacionController } from './presentation/http/afiliacion.controller';
import { ClientesController } from './presentation/http/clientes.controller';
import { MiQrController, RegistroController } from './presentation/http/registro.controller';

/**
 * EP-04 · El cliente se registra solo y tiene su QR personal; la caja lo afilia con un
 * escaneo, lo registra si no tiene app y lo busca, también sin internet (ADR-0017).
 */
@Module({
  imports: [AutenticacionModule],
  controllers: [RegistroController, MiQrController, AfiliacionController, ClientesController],
  providers: [
    { provide: POLITICA_REPOSITORY, useClass: PrismaPoliticaRepository },
    { provide: REGISTRO_REPOSITORY, useClass: PrismaRegistroRepository },
    { provide: MI_QR_REPOSITORY, useClass: PrismaMiQrRepository },
    { provide: CLIENTES_REPOSITORY, useClass: PrismaClientesRepository },
    ...PROVEEDORES_CLIENTES,
  ],
})
export class ClientesModule {}
