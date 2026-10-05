import { ErrorDeDominio } from '../../../../shared/domain/errores/error-de-dominio';

export class HorarioNoEncontrado extends ErrorDeDominio {
  readonly codigo = 'HORARIO_NO_ENCONTRADO';
  readonly tipo = 'no-encontrado' as const;

  constructor() {
    super('No encontramos ese horario. Puede que alguien lo haya cambiado: vuelve a cargar.');
  }
}

export class ServicioRepetido extends ErrorDeDominio {
  readonly codigo = 'SERVICIO_REPETIDO';
  readonly tipo = 'conflicto' as const;

  constructor() {
    super('Ya tienes un servicio con ese nombre.');
  }
}
