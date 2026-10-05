import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { DispositivoRequest } from '../../../autenticacion';

const CODIGO_DOCUMENTO = /^[A-Z][A-Z0-9_]*$/;
const NUMERO_DOCUMENTO = /^[0-9A-Za-z]{4,20}$/;

export class DocumentoRequest {
  @ApiProperty({ example: 'CC', description: 'Código del tipo de documento (catálogo)' })
  @Matches(CODIGO_DOCUMENTO, { message: 'tipoDocumento debe ser un código como CC' })
  tipoDocumento!: string;

  @ApiProperty({ example: '1124500777' })
  @Matches(NUMERO_DOCUMENTO, { message: 'Revisa el número de documento' })
  numeroDocumento!: string;
}

export class RegistroRequest extends DocumentoRequest {
  @ApiProperty({ example: 'Luz Marina' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  nombres!: string;

  @ApiPropertyOptional({ example: 'Chindoy' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  apellidos?: string;

  @ApiProperty({ example: '315 777 8888', description: 'Celular como lo escribe la persona' })
  @IsString()
  @MaxLength(20)
  celular!: string;

  @ApiProperty({ example: '190573', pattern: '^\\d{6}$' })
  @Matches(/^\d{6}$/, { message: 'El PIN son 6 números' })
  pin!: string;

  @ApiProperty({ format: 'uuid', description: 'Versión de la política que la persona aceptó' })
  @IsUUID()
  politicaVersionId!: string;

  @ApiProperty({ type: DispositivoRequest })
  @ValidateNested()
  @Type(() => DispositivoRequest)
  dispositivo!: DispositivoRequest;
}

export class TokenQrRequest {
  @ApiProperty({ description: 'Texto leído del QR, tal cual', example: 'VP1.eyJr…' })
  @IsString()
  @MaxLength(600)
  token!: string;
}

export class RegistroAsistidoRequest extends DocumentoRequest {
  @ApiPropertyOptional({ example: 'Luz Marina', description: 'Solo si la persona es nueva' })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  nombres?: string;

  @ApiPropertyOptional({ example: 'Chindoy' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  apellidos?: string;

  @ApiPropertyOptional({ example: '315 777 8888', description: 'Solo si la persona es nueva' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  celular?: string;

  @ApiPropertyOptional({
    description: 'El celular es de otra persona de la familia: queda solo de contacto',
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  celularCompartido?: boolean;

  @ApiProperty({
    format: 'uuid',
    description: 'Versión de la política que se le leyó y aceptó (confirmada por el cajero)',
  })
  @IsUUID()
  politicaVersionId!: string;
}
