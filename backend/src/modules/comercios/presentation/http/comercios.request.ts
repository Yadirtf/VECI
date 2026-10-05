import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

const CODIGO = /^[A-Z][A-Z0-9_]*$/;

export class RegistrarComercioRequest {
  @ApiProperty({ example: 'Restaurante La Vecina' })
  @IsString()
  @MinLength(3)
  @MaxLength(120)
  nombre!: string;

  @ApiProperty({ example: 'RESTAURANT', description: 'Código del tipo de negocio (catálogo)' })
  @Matches(CODIGO, { message: 'tipoNegocio debe ser un código como RESTAURANT' })
  tipoNegocio!: string;

  @ApiProperty({ enum: ['NIT', 'CC'] })
  @IsIn(['NIT', 'CC'])
  tipoDocumento!: string;

  @ApiProperty({ example: '900123456', description: 'NIT con o sin dígito de verificación' })
  @IsString()
  @MaxLength(20)
  numeroDocumento!: string;

  @ApiProperty({ example: '310 000 0101' })
  @IsString()
  @MaxLength(20)
  celular!: string;

  @ApiPropertyOptional({ example: 'hola@lavecina.co', nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  correo?: string | null;

  @ApiPropertyOptional({ example: 'https://lavecina.co/logo.png', nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  logoUrl?: string | null;

  @ApiPropertyOptional({
    example: 86001,
    nullable: true,
    type: Number,
    description: 'Municipio (DIVIPOLA) de la sede principal',
  })
  @IsOptional()
  @IsInt()
  municipioId?: number | null;

  @ApiPropertyOptional({ example: 'Barrio San Agustín', nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  direccion?: string | null;
}

export class PropietarioInvitadoRequest {
  @ApiProperty({ example: '312 456 7890' })
  @IsString()
  @MaxLength(20)
  celular!: string;

  @ApiProperty({ example: 'Rosa Elena' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  nombres!: string;

  @ApiPropertyOptional({ example: 'Chindoy' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  apellidos?: string;

  @ApiProperty({ example: 'CC' })
  @Matches(CODIGO, { message: 'tipoDocumento debe ser un código como CC' })
  tipoDocumento!: string;

  @ApiProperty({ example: '1124500777' })
  @Matches(/^[0-9A-Za-z]{4,20}$/, { message: 'Revisa el número de documento' })
  numeroDocumento!: string;
}

export class RegistrarParaPropietarioRequest extends RegistrarComercioRequest {
  @ApiProperty({ type: PropietarioInvitadoRequest })
  @ValidateNested()
  @Type(() => PropietarioInvitadoRequest)
  propietario!: PropietarioInvitadoRequest;
}

export class EditarComercioRequest {
  @ApiPropertyOptional({ example: 'Restaurante La Vecina' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  nombre?: string;

  @ApiPropertyOptional({ example: 'RESTAURANT' })
  @IsOptional()
  @Matches(CODIGO, { message: 'tipoNegocio debe ser un código como RESTAURANT' })
  tipoNegocio?: string;

  @ApiPropertyOptional({ example: '310 000 0101' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  celular?: string;

  @ApiPropertyOptional({ nullable: true, type: String, description: 'null lo quita' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  correo?: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, description: 'null lo quita' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  logoUrl?: string | null;
}
