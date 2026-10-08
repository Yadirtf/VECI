import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  ValidateNested,
} from 'class-validator';

const CODIGO = /^[A-Z][A-Z0-9_]*$/;

/** Los límites finos (3–60 letras, $1.000…) los revisa el dominio con mensajes claros. */
export class TipoRequest {
  @ApiProperty({ example: 'Tiquetera de 20 almuerzos' })
  @IsString()
  @MaxLength(120)
  nombre!: string;

  @ApiProperty({ example: 'LUNCH', description: 'Código de la unidad (lista de unidades)' })
  @Matches(CODIGO, { message: 'unidad debe ser un código como LUNCH' })
  unidad!: string;

  @ApiProperty({ example: 20 })
  @IsInt()
  unidades!: number;

  @ApiProperty({ example: 220000, description: 'Pesos, sin centavos' })
  @IsInt()
  precio!: number;

  @ApiProperty({ example: 30 })
  @IsInt()
  vigenciaDias!: number;
}

export class EstadoTipoRequest {
  @ApiProperty({ description: 'true: se vende. false: se guarda sin borrar lo vendido.' })
  @IsBoolean()
  activo!: boolean;
}

export class PagoRequest {
  @ApiProperty({ example: 'CASH', description: 'Código del medio de pago' })
  @Matches(CODIGO, { message: 'medio debe ser un código como CASH' })
  medio!: string;

  @ApiPropertyOptional({ example: 'NEQUI', description: 'Obligatorio en transferencias' })
  @IsOptional()
  @Matches(CODIGO, { message: 'canal debe ser un código como NEQUI' })
  canal?: string;

  @ApiPropertyOptional({ example: 'M123456', description: 'Referencia de la transferencia' })
  @IsOptional()
  @IsString()
  @MaxLength(60)
  referencia?: string;
}

export class VentaRequest {
  @ApiProperty({
    format: 'uuid',
    description: 'UUID v7 que genera la caja: reenviar la misma venta no la duplica',
  })
  @IsUUID()
  ventaId!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  clienteId!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  tipoId!: string;

  @ApiProperty({ example: 220000, description: 'Lo que se le cobró al cliente' })
  @IsInt()
  precio!: number;

  @ApiProperty({ type: PagoRequest })
  @ValidateNested()
  @Type(() => PagoRequest)
  pago!: PagoRequest;

  @ApiPropertyOptional({
    default: false,
    description: 'Se hizo sin señal y llega después: se respeta el precio y la hora de la caja',
  })
  @IsOptional()
  @IsBoolean()
  sinConexion?: boolean;

  @ApiPropertyOptional({
    format: 'date-time',
    description: 'Hora real de la venta hecha sin conexión',
  })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  ocurridaEn?: Date;
}

export class CorreccionRequest {
  @ApiProperty({ example: 'DATA_ENTRY_ERROR', description: 'Código de la lista de motivos' })
  @Matches(CODIGO, { message: 'Elige el motivo de la lista' })
  motivo!: string;

  @ApiPropertyOptional({ example: 'Se cobró dos veces', description: 'Obligatoria con "Otro"' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  nota?: string;
}

export class AjusteRequest extends CorreccionRequest {
  @ApiProperty({ example: -2, description: 'Unidades que suma (+) o quita (-), sin cero' })
  @IsInt()
  unidades!: number;
}
