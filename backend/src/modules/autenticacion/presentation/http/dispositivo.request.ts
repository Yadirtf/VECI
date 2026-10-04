import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import { Plataforma } from '../../application/puertos/sesiones.repository';

const PLATAFORMAS: Plataforma[] = ['ANDROID', 'IOS', 'WEB'];

/** El dispositivo genera y guarda su propio id (UUID v7) la primera vez que abre VECI. */
export class DispositivoRequest {
  @ApiProperty({ format: 'uuid', description: 'Id que el dispositivo generó para sí' })
  @IsUUID()
  id!: string;

  @ApiProperty({ enum: PLATAFORMAS })
  @IsIn(PLATAFORMAS)
  plataforma!: Plataforma;

  @ApiPropertyOptional({ example: 'Moto E13' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  modelo?: string;

  @ApiPropertyOptional({ example: 'Android 13' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  versionSo?: string;

  @ApiPropertyOptional({ example: '0.2.0' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  versionApp?: string;
}
