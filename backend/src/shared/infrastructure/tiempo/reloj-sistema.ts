import { Reloj } from '../../application/puertos/reloj.port';

export class RelojSistema implements Reloj {
  ahora(): Date {
    return new Date();
  }
}
