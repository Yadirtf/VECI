import { describe, expect, it } from 'vitest';
import { problemaConContrasena, problemaConPinNuevo } from './cuenta';

describe('mi cuenta', () => {
  it('revisa el PIN nuevo antes de enviarlo', () => {
    expect(problemaConPinNuevo('246813', '730284', '730284')).toBeNull();
    expect(problemaConPinNuevo('246813', '7302', '7302')).toMatch(/6 números/);
    expect(problemaConPinNuevo('246813', '730284', '730285')).toMatch(/no coinciden/);
    expect(problemaConPinNuevo('246813', '246813', '246813')).toMatch(/distinto/);
  });

  it('revisa el correo y el largo de la contraseña', () => {
    expect(problemaConContrasena('marta@lavecina.co', 'almuerzo2026')).toBeNull();
    expect(problemaConContrasena('marta', 'almuerzo2026')).toMatch(/correo/);
    expect(problemaConContrasena('marta@lavecina.co', 'corta')).toMatch(/8 caracteres/);
  });
});
