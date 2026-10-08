import { ApiProperty } from '@nestjs/swagger';

export class UnidadResponse {
  @ApiProperty({ example: 'LUNCH' })
  codigo!: string;

  @ApiProperty({ example: 'almuerzo' })
  singular!: string;

  @ApiProperty({ example: 'almuerzos' })
  plural!: string;
}

export class TipoResponse {
  @ApiProperty({ format: 'uuid' })
  tipoId!: string;

  @ApiProperty({ example: 'Tiquetera de 20 almuerzos' })
  nombre!: string;

  @ApiProperty({ type: UnidadResponse })
  unidad!: UnidadResponse;

  @ApiProperty({ example: 20 })
  unidades!: number;

  @ApiProperty({ example: 220000, description: 'Pesos, sin centavos' })
  precio!: number;

  @ApiProperty({ example: 11000, description: 'Lo que sale cada unidad, redondeado' })
  precioPorUnidad!: number;

  @ApiProperty({ example: 30, description: 'Días que sirve desde la compra' })
  vigenciaDias!: number;

  @ApiProperty({ enum: ['ACTIVE', 'INACTIVE', 'ARCHIVED'], description: 'Solo el activo se vende' })
  estado!: string;

  @ApiProperty({ example: 12, description: 'Tiqueteras vendidas de este tipo' })
  vendidas!: number;

  @ApiProperty({ example: 4, description: 'Vendidas que siguen con unidades por servir' })
  vigentes!: number;
}

export class CanalResponse {
  @ApiProperty({ example: 'NEQUI' })
  codigo!: string;

  @ApiProperty({ example: 'Nequi' })
  nombre!: string;
}

export class MedioDePagoResponse {
  @ApiProperty({ example: 'BANK_TRANSFER' })
  codigo!: string;

  @ApiProperty({ example: 'Transferencia' })
  nombre!: string;

  @ApiProperty({ description: 'Hay que decir por cuál canal llegó' })
  necesitaCanal!: boolean;

  @ApiProperty({ type: CanalResponse, isArray: true })
  canales!: CanalResponse[];
}

export class CatalogoDeVentaResponse {
  @ApiProperty({ example: '7.3', description: 'Va también en el ETag' })
  version!: string;

  @ApiProperty({ type: TipoResponse, isArray: true, description: 'Solo los activos' })
  tipos!: TipoResponse[];

  @ApiProperty({ type: MedioDePagoResponse, isArray: true })
  medios!: MedioDePagoResponse[];
}

export class MotivoResponse {
  @ApiProperty({ example: 'DATA_ENTRY_ERROR' })
  codigo!: string;

  @ApiProperty({ example: 'Error al registrar' })
  nombre!: string;
}
