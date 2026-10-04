import { esPinFacilDeAdivinar } from './pin-facil-de-adivinar.rule';

describe('esPinFacilDeAdivinar', () => {
  it.each(['000000', '111111', '123456', '654321', '987654', '121212', '123123', '112233'])(
    'rechaza %s',
    (pin) => expect(esPinFacilDeAdivinar(pin)).toBe(true),
  );

  it.each(['482915', '730284', '190573', '246813'])('acepta %s', (pin) =>
    expect(esPinFacilDeAdivinar(pin)).toBe(false),
  );
});
