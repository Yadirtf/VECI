-- =============================================================================
-- 20 · Semillas de catálogos y máquinas de estado
-- Los id son estables entre entornos; el código de la aplicación usa code.
-- =============================================================================

-- ---------------------------------------------------------------- core
INSERT INTO core.modules (id, code, name) VALUES
  (1,'AUTH','Autenticación'), (2,'TENANCY','Comercios y sedes'), (3,'CUSTOMERS','Clientes'),
  (4,'PREPAID','Tiqueteras'), (5,'CONSUMPTIONS','Consumos'), (6,'SYNC','Sincronización'),
  (7,'REPORTS','Reportes'), (8,'NOTIFICATIONS','Notificaciones'), (9,'BILLING','Suscripciones'),
  (10,'COMPLIANCE','Protección de datos'), (11,'PLATFORM','Administración VECI');

INSERT INTO core.currencies VALUES ('COP','Peso colombiano',2);
INSERT INTO core.countries VALUES (1,'CO','Colombia','+57');
INSERT INTO core.departments VALUES (1,1,'86','Putumayo');
INSERT INTO core.municipalities (id, department_id, official_code, name) VALUES
  (86001,1,'86001','Mocoa'), (86219,1,'86219','Colón'), (86320,1,'86320','Orito'),
  (86568,1,'86568','Puerto Asís'), (86569,1,'86569','Puerto Caicedo'),
  (86571,1,'86571','Puerto Guzmán'), (86573,1,'86573','Puerto Leguízamo'),
  (86749,1,'86749','Sibundoy'), (86755,1,'86755','San Francisco'),
  (86757,1,'86757','San Miguel'), (86760,1,'86760','Santiago'),
  (86865,1,'86865','Valle del Guamuez'), (86885,1,'86885','Villagarzón');

INSERT INTO core.document_types (id, code, name, country_id, for_natural_person, for_legal_entity, validation_regex, sort_order) VALUES
  (1,'CC','Cédula de ciudadanía',1,true,false,'^[0-9]{6,10}$',1),
  (2,'TI','Tarjeta de identidad',1,true,false,'^[0-9]{10,11}$',2),
  (3,'RC','Registro civil',1,true,false,'^[0-9]{10,11}$',3),
  (4,'CE','Cédula de extranjería',1,true,false,'^[0-9]{6,7}$',4),
  (5,'PPT','Permiso por protección temporal',1,true,false,NULL,5),
  (6,'PASSPORT','Pasaporte',1,true,false,NULL,6),
  (7,'NIT','NIT',1,true,true,'^[0-9]{9,10}$',7);

INSERT INTO core.contact_types (id, code, name, can_login, validation_regex) VALUES
  (1,'MOBILE_PHONE','Celular',true,'^\+[1-9][0-9]{7,14}$'),
  (2,'EMAIL','Correo electrónico',true,'^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  (3,'WHATSAPP','WhatsApp',false,'^\+[1-9][0-9]{7,14}$'),
  (4,'LANDLINE','Teléfono fijo',false,NULL);

INSERT INTO core.weekdays VALUES
  (1,'MONDAY','Lunes'), (2,'TUESDAY','Martes'), (3,'WEDNESDAY','Miércoles'), (4,'THURSDAY','Jueves'),
  (5,'FRIDAY','Viernes'), (6,'SATURDAY','Sábado'), (7,'SUNDAY','Domingo');

INSERT INTO core.data_types VALUES
  (1,'INTEGER','Entero'), (2,'DECIMAL','Decimal'), (3,'BOOLEAN','Sí/No'), (4,'TEXT','Texto'), (5,'TIME','Hora');

INSERT INTO core.payment_methods (id, code, name, needs_channel, sort_order, is_active) VALUES
  (1,'CASH','Efectivo',false,1,true),
  (2,'BANK_TRANSFER','Transferencia',true,2,true),
  (3,'ONLINE_GATEWAY','Pago en línea',true,3,false);

INSERT INTO core.payment_channels (id, payment_method_id, code, name, sort_order, is_active) VALUES
  (1,2,'NEQUI','Nequi',1,true), (2,2,'DAVIPLATA','Daviplata',2,true),
  (3,2,'BANCOLOMBIA','Bancolombia',3,true), (4,3,'WOMPI','Wompi',4,false);

INSERT INTO core.qr_revocation_reasons (id, code, name) VALUES
  (1,'REGENERATED','Regenerado a pedido'), (2,'LOST','Perdido'), (3,'SHARED_OR_COMPROMISED','Compartido o comprometido'),
  (4,'AFFILIATION_ENDED','Afiliación terminada'), (5,'PERSON_ANONYMIZED','Datos eliminados (habeas data)');

-- ---------------------------------------------------------------- identity
INSERT INTO identity.person_statuses (id, code, name, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activa',true,false), (2,'ANONYMIZED','Anonimizada',false,true);
INSERT INTO identity.person_status_transitions VALUES (1,2);

INSERT INTO identity.user_statuses (id, code, name, allows_login, is_initial, is_terminal) VALUES
  (1,'PENDING_ACTIVATION','Pendiente de activar',false,true,false),
  (2,'ACTIVE','Activo',true,false,false),
  (3,'SUSPENDED','Suspendido por VECI',false,false,false),
  (4,'CLOSED','Cerrado',false,false,true);
INSERT INTO identity.user_status_transitions VALUES (1,2),(1,4),(2,3),(3,2),(2,4),(3,4);

INSERT INTO identity.credential_types (id, code, name, max_failed_attempts, lock_minutes, is_active) VALUES
  (1,'PIN','PIN de 6 dígitos',5,15,true), (2,'PASSWORD','Contraseña',5,15,true),
  (3,'OTP','Código de un solo uso (WhatsApp o SMS)',3,15,false);
INSERT INTO identity.credential_revocation_reasons VALUES
  (1,'CHANGED_BY_USER','Cambiado por el usuario'), (2,'RESET_BY_OWNER','Restablecido por el propietario'),
  (3,'RESET_BY_SUPPORT','Restablecido por soporte VECI'), (4,'USER_CLOSED','Cuenta cerrada');
INSERT INTO identity.login_failure_reasons VALUES
  (1,'UNKNOWN_IDENTIFIER','Celular o correo no registrado'), (2,'WRONG_SECRET','PIN o contraseña incorrectos'),
  (3,'CREDENTIAL_LOCKED','Bloqueo temporal por intentos'), (4,'USER_NOT_ALLOWED','Usuario no habilitado'),
  (5,'MEMBERSHIP_NOT_ALLOWED','Sin acceso activo al comercio');
INSERT INTO identity.session_revocation_reasons VALUES
  (1,'LOGOUT','Cierre de sesión'), (2,'REMOTE_LOGOUT','Cierre remoto desde el panel'),
  (3,'CREDENTIAL_RESET','PIN restablecido'), (4,'USER_SUSPENDED','Usuario suspendido'),
  (5,'MEMBERSHIP_ENDED','Retirado del comercio'), (6,'TOKEN_REUSE_DETECTED','Reutilización de token detectada');
INSERT INTO identity.device_platforms VALUES (1,'ANDROID','Android'), (2,'IOS','iOS'), (3,'WEB','Navegador');

-- ---------------------------------------------------------------- tenancy
INSERT INTO tenancy.business_types (id, code, name, sort_order, is_active) VALUES
  (1,'RESTAURANT','Restaurante',1,true), (2,'CAFETERIA','Cafetería',2,true), (3,'BAKERY','Panadería',3,true),
  (4,'SCHOOL','Colegio',4,true), (5,'STORE','Tienda de barrio',5,true), (6,'OTHER','Otro',99,true);

INSERT INTO tenancy.tenant_statuses (id, code, name, allows_operations, is_initial, is_terminal) VALUES
  (1,'ONBOARDING','En configuración',false,true,false), (2,'ACTIVE','Activo',true,false,false),
  (3,'SUSPENDED','Suspendido por VECI',false,false,false), (4,'CLOSED','Cerrado',false,false,true);
INSERT INTO tenancy.tenant_status_transitions VALUES (1,2),(1,4),(2,3),(3,2),(2,4),(3,4);

INSERT INTO tenancy.branch_statuses (id, code, name, allows_operations) VALUES
  (1,'ACTIVE','Activa',true), (2,'INACTIVE','Inactiva',false), (3,'CLOSED','Cerrada',false);
INSERT INTO tenancy.branch_status_transitions VALUES (1,2),(2,1),(1,3),(2,3);

INSERT INTO tenancy.membership_statuses (id, code, name, allows_login, is_initial, is_terminal) VALUES
  (1,'INVITED','Invitado',false,true,false), (2,'ACTIVE','Activo',true,false,false),
  (3,'SUSPENDED','Suspendido',false,false,false), (4,'REMOVED','Retirado',false,false,false);
-- Retirado → Invitado: un cajero recontratado se vuelve a invitar (HU-02-04).
INSERT INTO tenancy.membership_status_transitions VALUES (1,2),(1,4),(2,3),(3,2),(2,4),(3,4),(4,1);

-- ---------------------------------------------------------------- customers
INSERT INTO customers.affiliation_statuses (id, code, name, allows_operations, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activa',true,true,false), (2,'BLOCKED','Bloqueada por el comercio',false,false,false),
  (3,'ENDED','Retirada',false,false,true);
INSERT INTO customers.affiliation_status_transitions VALUES (1,2),(2,1),(1,3),(2,3);
INSERT INTO customers.affiliation_channels VALUES
  (1,'PERSONAL_QR_SCAN','Escaneo del QR personal'), (2,'ASSISTED_REGISTRATION','Registro asistido por el cajero'),
  (3,'DATA_IMPORT','Importación de datos');

-- ---------------------------------------------------------------- prepaid
INSERT INTO prepaid.package_type_statuses (id, code, name, allows_sale, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activo',true,true,false), (2,'INACTIVE','Inactivo',false,false,false),
  (3,'ARCHIVED','Archivado',false,false,true);
INSERT INTO prepaid.package_type_status_transitions VALUES (1,2),(2,1),(2,3);

INSERT INTO prepaid.package_statuses (id, code, name, allows_consumption, counts_as_liability, is_initial, is_terminal) VALUES
  (1,'ACTIVE','Activa',true,true,true,false), (2,'DEPLETED','Agotada',false,false,false,false),
  (3,'EXPIRED','Vencida',false,false,false,true), (4,'VOIDED','Anulada',false,false,false,true);
INSERT INTO prepaid.package_status_transitions VALUES (1,2),(2,1),(1,3),(1,4),(2,4);

INSERT INTO prepaid.consumption_units (tenant_id, code, singular_name, plural_name) VALUES
  (NULL,'LUNCH','almuerzo','almuerzos'), (NULL,'BREAKFAST','desayuno','desayunos'),
  (NULL,'DINNER','cena','cenas'), (NULL,'MEAL','comida','comidas'), (NULL,'COFFEE','café','cafés'),
  (NULL,'BREAD','pan','panes'), (NULL,'UNIT','unidad','unidades');

-- ---------------------------------------------------------------- ledger
INSERT INTO ledger.event_types (id, code, name, balance_effect, requires_actor, requires_reason, is_reversal, is_reversible, notifies_customer) VALUES
  (1,'SALE','Venta de tiquetera',1,true,false,false,true,true),
  (2,'CONSUMPTION','Consumo',-1,true,false,false,true,true),
  (3,'CONSUMPTION_REVERSAL','Reverso de consumo',1,true,true,true,false,true),
  (4,'SALE_VOID','Anulación de venta',-1,true,true,true,false,true),
  (5,'ADJUSTMENT','Ajuste de saldo',0,true,true,false,false,true),
  (6,'EXPIRATION','Vencimiento',-1,false,false,false,false,false);
INSERT INTO ledger.event_origins VALUES
  (1,'ONLINE','En línea'), (2,'OFFLINE_SYNC','Sincronizado desde el celular'),
  (3,'SYSTEM_JOB','Proceso automático'), (4,'PLATFORM_CONSOLE','Consola VECI');
INSERT INTO ledger.event_reasons (id, code, name, sort_order) VALUES
  (1,'DATA_ENTRY_ERROR','Error al registrar',1), (2,'CUSTOMER_CLAIM','Reclamo del cliente',2),
  (3,'DUPLICATE_RECORD','Registro duplicado',3), (4,'COURTESY','Cortesía',4),
  (5,'AUTHORIZED_EXTRA_SERVICE','Consumo adicional autorizado',5), (6,'CONFLICT_RESOLUTION','Resolución de conflicto',6),
  (7,'OTHER','Otro',99);

-- ---------------------------------------------------------------- sales y consumos
INSERT INTO sales.sale_statuses (id, code, name, counts_as_revenue, is_initial, is_terminal) VALUES
  (1,'COMPLETED','Completada',true,true,false), (2,'VOIDED','Anulada',false,false,true);
INSERT INTO sales.sale_status_transitions VALUES (1,2);
INSERT INTO consumptions.capture_methods VALUES (1,'QR_SCAN','Escaneo de QR'), (2,'MANUAL_SEARCH','Búsqueda manual');

-- ---------------------------------------------------------------- sync
INSERT INTO sync.inbound_event_kinds VALUES
  (1,'SALE','Venta'), (2,'CONSUMPTION','Consumo'), (3,'CONSUMPTION_REVERSAL','Reverso de consumo'),
  (4,'AFFILIATION','Afiliación'), (5,'ASSISTED_REGISTRATION','Registro asistido');
INSERT INTO sync.inbound_event_statuses VALUES
  (1,'RECEIVED','Recibido',false), (2,'APPLIED','Aplicado',true),
  (3,'APPLIED_WITH_CONFLICT','Aplicado con conflicto',true), (4,'REJECTED','Rechazado',true);
INSERT INTO sync.inbound_event_status_transitions VALUES (1,2),(1,3),(1,4);
INSERT INTO sync.rejection_reasons VALUES
  (1,'INVALID_SIGNATURE','Firma del QR inválida'), (2,'QR_FROM_OTHER_TENANT','QR de otro comercio'),
  (3,'TENANT_READ_ONLY','Comercio en solo lectura'), (4,'MEMBERSHIP_NOT_ALLOWED','Cajero sin acceso'),
  (5,'VALIDATION_ERROR','Datos inválidos'), (6,'UNKNOWN_REFERENCE','Referencia inexistente');
INSERT INTO sync.conflict_types (id, code, name) VALUES
  (1,'DOUBLE_CONSUMPTION_SAME_SERVICE','Dos consumos en el mismo horario'),
  (2,'NEGATIVE_BALANCE','Saldo negativo'), (3,'CONSUMPTION_ON_EXPIRED_PACKAGE','Consumo con tiquetera vencida'),
  (4,'REVOKED_QR_USED','Consumo con QR revocado');
INSERT INTO sync.conflict_statuses (id, code, name, is_initial, is_terminal) VALUES
  (1,'OPEN','Abierto',true,false), (2,'ACCEPTED','Aceptado',false,true), (3,'REVERSED','Reversado',false,true);
INSERT INTO sync.conflict_status_transitions VALUES (1,2),(1,3);
