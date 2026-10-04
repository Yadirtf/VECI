import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, Matches, MaxLength, MinLength } from 'class-validator';
import { AccionCajero } from '../../application/use-cases/cambiar-estado-cajero.use-case';

const ACCIONES: AccionCajero[] = ['SUSPENDER', 'REACTIVAR', 'RETIRAR'];

export class InvitarCajeroRequest {
  @ApiProperty({ example: '312 456 7890' })
  @IsString()
  @MaxLength(20)
  celular!: string;

  @ApiProperty({ example: 'Ana Lucía' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  nombres!: string;

  @ApiPropertyOptional({ example: 'Jacanamejoy' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  apellidos?: string;

  @ApiProperty({ example: 'CC', description: 'Código del tipo de documento (catálogo)' })
  @Matches(/^[A-Z][A-Z0-9_]*$/, { message: 'tipoDocumento debe ser un código como CC' })
  tipoDocumento!: string;

  @ApiProperty({ example: '1124500777' })
  @Matches(/^[0-9A-Za-z]{4,20}$/, { message: 'Revisa el número de documento' })
  numeroDocumento!: string;
}

export class CambiarEstadoCajeroRequest {
  @ApiProperty({ enum: ACCIONES })
  @IsIn(ACCIONES)
  accion!: AccionCajero;
}
