/// Por qué la caja no acepta un QR. Cada motivo tiene su mensaje amable.
enum ScanRejection {
  formatoInvalido('Este código no es un QR de VECI.'),
  sinDatosOffline('Primero baja los datos del negocio con internet.'),
  otroComercio('Este QR es de otro negocio. Pídele al cliente el QR de aquí.'),
  claveDesconocida('No reconozco la firma de este QR. Sincroniza y vuelve a intentar.'),
  firmaInvalida('Este QR fue alterado. No lo aceptes.'),
  qrRevocado('Este QR fue reemplazado. El cliente debe mostrar el nuevo.');

  const ScanRejection(this.message);

  final String message;
}
