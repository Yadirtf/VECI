//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library veci_api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/equipo_del_negocio_api.dart';
part 'api/horarios_de_servicio_api.dart';
part 'api/mi_cuenta_api.dart';
part 'api/salud_api.dart';
part 'api/sesiones_api.dart';
part 'api/soporte_veci_api.dart';

part 'model/cambiar_estado_cajero_request.dart';
part 'model/cambiar_pin_request.dart';
part 'model/cierre_remoto_response.dart';
part 'model/comercio_activo_request.dart';
part 'model/comercio_activo_response.dart';
part 'model/correo_response.dart';
part 'model/correo_y_contrasena_request.dart';
part 'model/crear_horario_request.dart';
part 'model/dispositivo_request.dart';
part 'model/dispositivo_response.dart';
part 'model/espacio_response.dart';
part 'model/horario_response.dart';
part 'model/ingreso_con_contrasena_request.dart';
part 'model/ingreso_con_pin_request.dart';
part 'model/ingreso_response.dart';
part 'model/invitacion_response.dart';
part 'model/invitar_cajero_request.dart';
part 'model/miembro_response.dart';
part 'model/pin_cliente_response.dart';
part 'model/pin_nuevo_request.dart';
part 'model/pin_temporal_response.dart';
part 'model/renovar_sesion_request.dart';
part 'model/respuesta_error_dto.dart';
part 'model/restablecer_pin_cliente_request.dart';
part 'model/salud_response.dart';
part 'model/sesion_en_dispositivo_response.dart';
part 'model/sesion_response.dart';
part 'model/usuario_response.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
