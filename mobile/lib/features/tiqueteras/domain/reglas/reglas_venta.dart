import '../entities/catalogo.dart';
import '../entities/venta.dart';

/// "$ 220.000": pesos sin centavos, con punto de miles.
String pesos(int valor) {
  final digitos = valor.abs().toString();
  final grupos = <String>[];
  for (var fin = digitos.length; fin > 0; fin -= 3) {
    grupos.insert(0, digitos.substring(fin - 3 < 0 ? 0 : fin - 3, fin));
  }
  return '${valor < 0 ? '-' : ''}\$ ${grupos.join('.')}';
}

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "2026-11-06" → "6 nov".
String diaLegible(String dia) {
  final partes = dia.split('-');
  if (partes.length != 3) return dia;
  return '${int.parse(partes[2])} ${_meses[int.parse(partes[1]) - 1]}';
}

/// El pago listo para la venta, o lo que falta en palabras de vecino.
({Pago? pago, String? falta}) armarPago(MedioDePago? medio, String? canal, String referencia) {
  if (medio == null) return (pago: null, falta: 'Elige cómo pagó.');
  if (!medio.necesitaCanal) return (pago: Pago(medio: medio.codigo), falta: null);
  if (canal == null || canal.isEmpty) {
    return (pago: null, falta: '¿Por dónde llegó la transferencia? Nequi, Daviplata…');
  }
  final limpia = referencia.trim();
  return (
    pago: Pago(medio: medio.codigo, canal: canal, referencia: limpia.isEmpty ? null : limpia),
    falta: null,
  );
}

/// Qué dice cada renglón de la historia.
const textoMovimiento = {
  'SALE': 'Compró',
  'CONSUMPTION': 'Consumió',
  'CONSUMPTION_REVERSAL': 'Se devolvió un consumo',
  'SALE_VOID': 'Venta anulada',
  'ADJUSTMENT': 'Ajuste',
  'EXPIRATION': 'Venció',
};
