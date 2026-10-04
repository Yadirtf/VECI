import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:veci_api/api.dart';

const _claveId = 'veci.dispositivo';

/// Este celular como dispositivo de VECI: un id propio que se guarda la primera vez y
/// el modelo, para que la propietaria lo reconozca en su lista (HU-02-06).
class DispositivoLocal {
  DispositivoLocal(this._almacen, [DeviceInfoPlugin? info]) : _info = info ?? DeviceInfoPlugin();

  final FlutterSecureStorage _almacen;
  final DeviceInfoPlugin _info;
  DispositivoRequest? _descripcion;

  Future<DispositivoRequest> describir() async => _descripcion ??= await _armar();

  Future<DispositivoRequest> _armar() async {
    final (modelo, version) = await _modeloYVersion();
    return DispositivoRequest(
      id: await _leerOCrear(),
      plataforma: Platform.isIOS
          ? DispositivoRequestPlataformaEnum.IOS
          : DispositivoRequestPlataformaEnum.ANDROID,
      modelo: _recortar(modelo, 80),
      versionSo: _recortar(version, 40),
      versionApp: const String.fromEnvironment('VECI_VERSION', defaultValue: 'local'),
    );
  }

  Future<(String, String)> _modeloYVersion() async {
    try {
      if (Platform.isIOS) {
        final ios = await _info.iosInfo;
        return (ios.utsname.machine, 'iOS ${ios.systemVersion}');
      }
      final android = await _info.androidInfo;
      return ('${android.manufacturer} ${android.model}', 'Android ${android.version.release}');
    } on Exception {
      return ('Celular', Platform.operatingSystem);
    }
  }

  Future<String> _leerOCrear() async {
    final guardado = await _almacen.read(key: _claveId);
    if (guardado != null) return guardado;
    final nuevo = uuidV4(Random.secure());
    await _almacen.write(key: _claveId, value: nuevo);
    return nuevo;
  }
}

String _recortar(String texto, int maximo) =>
    texto.length <= maximo ? texto : texto.substring(0, maximo);

/// UUID versión 4 (aleatorio), sin depender de otro paquete.
String uuidV4(Random azar) {
  final bytes = List<int>.generate(16, (_) => azar.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
