import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

export class CrearSedeRequest {
  @ApiProperty({ example: 'Sede del parque' })
  @IsString()
  @MaxLength(120)
  nombre!: string;

  @ApiPropertyOptional({ example: 86001, nullable: true, type: Number })
  @IsOptional()
  @IsInt()
  municipioId?: number | null;

  @ApiPropertyOptional({ example: 'Calle 8 # 5-20', nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  direccion?: string | null;
}

export class EditarSedeRequest {
  @ApiPropertyOptional({ example: 'Sede del parque' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  nombre?: string;

  @ApiPropertyOptional({ nullable: true, type: Number })
  @IsOptional()
  @IsInt()
  municipioId?: number | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  direccion?: string | null;

  @ApiPropertyOptional({ description: 'false desactiva la sede; true la reabre' })
  @IsOptional()
  @IsBoolean()
  activa?: boolean;
}

export class AsignarSedesRequest {
  @ApiProperty({ type: [String], description: 'Vacío = trabaja en todas las sedes' })
  @IsArray()
  @ArrayMaxSize(50)
  @IsUUID('all', { each: true })
  sedeIds!: string[];
}

export class SedeResponse {
  @ApiProperty({ format: 'uuid' })
  sedeId!: string;

  @ApiProperty({ example: 'Principal' })
  nombre!: string;

  @ApiProperty()
  principal!: boolean;

  @ApiProperty({ example: 'ACTIVE' })
  estado!: string;

  @ApiProperty()
  activa!: boolean;

  @ApiPropertyOptional({ nullable: true, type: Number })
  municipioId!: number | null;

  @ApiPropertyOptional({ nullable: true, type: String, example: 'Mocoa' })
  municipio!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  direccion!: string | null;
}

export class CajeroEnSedesResponse {
  @ApiProperty({ format: 'uuid' })
  membresiaId!: string;

  @ApiProperty({ example: 'Jhon Mutumbajoy' })
  nombre!: string;

  @ApiProperty({ type: [String], description: 'Vacío = trabaja en todas' })
  sedeIds!: readonly string[];
}

export class CupoDeSedesResponse {
  @ApiProperty({ example: 1 })
  ocupadas!: number;

  @ApiPropertyOptional({ nullable: true, type: Number, description: 'null = sin límite' })
  limite!: number | null;

  @ApiProperty({ description: 'El plan permite varias sedes (plan Pro)' })
  variasSedes!: boolean;
}

export class MapaDeSedesResponse {
  @ApiProperty({ type: SedeResponse, isArray: true })
  sedes!: SedeResponse[];

  @ApiProperty({ type: CajeroEnSedesResponse, isArray: true })
  cajeros!: CajeroEnSedesResponse[];

  @ApiProperty({ type: CupoDeSedesResponse })
  cupo!: CupoDeSedesResponse;
}
