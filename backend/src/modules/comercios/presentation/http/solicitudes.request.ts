import { ApiProperty, OmitType } from '@nestjs/swagger';
import { IsInt, IsString, MaxLength, MinLength } from 'class-validator';
import { RegistrarComercioRequest } from './comercios.request';

/** Los mismos datos del alta, con el municipio obligatorio (cobertura). */
export class SolicitarRegistroRequest extends OmitType(RegistrarComercioRequest, [
  'municipioId',
] as const) {
  @ApiProperty({ example: 86001, description: 'Municipio (DIVIPOLA) donde queda el negocio' })
  @IsInt()
  municipioId!: number;
}

export class RechazoSolicitudRequest {
  @ApiProperty({ example: 'El NIT no corresponde al negocio. Revísalo y vuelve a pedirlo.' })
  @IsString()
  @MinLength(10)
  @MaxLength(500)
  motivo!: string;
}
