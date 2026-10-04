-- =============================================================================
-- 21 · Semillas: roles, permisos, ajustes, planes, notificaciones, cumplimiento
-- =============================================================================

-- ---------------------------------------------------------------- roles
INSERT INTO identity.roles (id, code, name, assignable_to_platform, assignable_to_membership) VALUES
  (1,'VECI_ADMIN','Administrador VECI',true,false),
  (2,'VECI_SUPPORT','Soporte VECI',true,false),
  (3,'OWNER','Propietario',false,true),
  (4,'CASHIER','Cajero',false,true),
  (5,'CUSTOMER','Cliente',false,false);

-- ---------------------------------------------------------------- permisos
INSERT INTO identity.permissions (id, module_id, code, name) VALUES
  (1,2,'tenancy.view_tenant','Ver datos del comercio'),
  (2,2,'tenancy.manage_tenant','Editar datos del comercio'),
  (3,2,'tenancy.manage_branches','Gestionar sedes'),
  (4,2,'tenancy.manage_schedules','Gestionar horarios de servicio'),
  (5,2,'tenancy.manage_staff','Invitar, suspender y retirar cajeros'),
  (6,2,'tenancy.reset_staff_pin','Restablecer PIN de cajeros'),
  (7,2,'tenancy.revoke_devices','Cerrar sesiones de dispositivos'),
  (8,2,'tenancy.manage_settings','Cambiar configuraciones'),
  (9,3,'customers.register','Registrar clientes'),
  (10,3,'customers.affiliate','Afiliar clientes'),
  (11,3,'customers.search','Buscar clientes'),
  (12,3,'customers.view_full_document','Ver documento completo'),
  (13,3,'customers.manage_qr','Revocar y regenerar QR'),
  (14,3,'customers.block','Bloquear afiliaciones'),
  (15,4,'prepaid.manage_package_types','Gestionar tipos de tiquetera'),
  (16,4,'prepaid.sell','Vender tiqueteras'),
  (17,4,'prepaid.void_sale','Anular ventas'),
  (18,4,'prepaid.adjust_balance','Ajustar saldos'),
  (19,5,'consumptions.register','Registrar consumos'),
  (20,5,'consumptions.authorize_extra','Autorizar consumo adicional en el horario'),
  (21,5,'consumptions.reverse_own_recent','Reversar consumos propios recientes'),
  (22,5,'consumptions.reverse_any','Reversar cualquier consumo'),
  (23,6,'sync.push_events','Sincronizar eventos'),
  (24,6,'sync.resolve_conflicts','Resolver conflictos'),
  (25,7,'reports.view_dashboard','Ver tablero y reportes'),
  (26,7,'reports.export','Exportar reportes'),
  (27,7,'reports.cash_closing','Hacer cierre de caja'),
  (28,9,'billing.view_subscription','Ver suscripción'),
  (29,9,'billing.manage_plans','Gestionar planes'),
  (30,9,'billing.record_payment','Registrar pagos de suscripción'),
  (31,11,'platform.manage_tenants','Administrar comercios'),
  (32,11,'platform.reset_customer_pin','Restablecer PIN de clientes'),
  (33,10,'compliance.manage_data_requests','Atender solicitudes de habeas data'),
  (34,3,'me.view_balances','Ver mis saldos y QR'),
  (35,3,'me.manage_profile','Gestionar mi perfil'),
  (36,10,'me.request_data_rights','Solicitar ver, corregir o eliminar mis datos'),
  (37,10,'compliance.view_audit_log','Consultar la bitácora de auditoría');

INSERT INTO identity.role_permissions (role_id, permission_id)
SELECT r.id, p.id
  FROM identity.roles r
  JOIN identity.permissions p ON
       (r.code = 'OWNER' AND split_part(p.code, '.', 1) IN ('tenancy','customers','prepaid','consumptions','sync','reports'))
    OR (r.code = 'OWNER' AND p.code IN ('billing.view_subscription','compliance.view_audit_log'))
    OR (r.code = 'CASHIER' AND p.code IN ('tenancy.view_tenant','customers.register','customers.affiliate',
          'customers.search','prepaid.sell','consumptions.register','consumptions.authorize_extra',
          'consumptions.reverse_own_recent','sync.push_events','reports.cash_closing'))
    OR (r.code = 'VECI_ADMIN' AND (split_part(p.code, '.', 1) IN ('platform','billing')
          OR p.code IN ('tenancy.view_tenant','compliance.manage_data_requests','compliance.view_audit_log')))
    OR (r.code = 'VECI_SUPPORT' AND p.code IN ('tenancy.view_tenant','platform.reset_customer_pin',
          'compliance.manage_data_requests','billing.view_subscription'))
    OR (r.code = 'CUSTOMER' AND split_part(p.code, '.', 1) = 'me');

-- ---------------------------------------------------------------- ajustes
INSERT INTO tenancy.setting_definitions (id, module_id, code, name, data_type_id, default_value, min_value, max_value) VALUES
  (1,8,'RENEWAL_REMINDER_UNITS','Avisar renovación al quedar N unidades',1,'2',1,50),
  (2,7,'INACTIVITY_DAYS','Días sin consumo para considerar inactivo',1,'15',1,365),
  (3,7,'LOW_BALANCE_REPORT_UNITS','Unidades para "próximo a terminar" en reportes',1,'3',1,50),
  (4,5,'CASHIER_REVERSAL_WINDOW_MINUTES','Minutos en que el cajero puede reversar',1,'10',0,1440),
  (5,5,'ONE_CONSUMPTION_PER_SERVICE','Un consumo por horario de servicio',3,'true',NULL,NULL),
  (6,5,'DEFAULT_CONSUMPTION_UNITS','Unidades por defecto al escanear',1,'1',1,20),
  (7,6,'LATE_SYNC_NOTICE_MINUTES','Minutos para explicar un consumo sincronizado tarde',1,'5',1,1440),
  (8,8,'DAILY_SUMMARY_TIME','Hora del resumen diario',5,'20:00',NULL,NULL);

-- ---------------------------------------------------------------- planes
INSERT INTO billing.billing_periods VALUES (1,'MONTHLY','Mensual',1), (2,'YEARLY','Anual',12);
INSERT INTO billing.limit_types (id, code, name) VALUES
  (1,'ACTIVE_CUSTOMERS','Clientes activos'), (2,'CASHIERS','Cajeros'), (3,'BRANCHES','Sedes');
INSERT INTO billing.features (id, code, name) VALUES
  (1,'MULTI_BRANCH','Varias sedes'), (2,'REPORT_EXPORT','Exportar reportes'),
  (3,'WHATSAPP_NOTIFICATIONS','Avisos por WhatsApp'), (4,'DAILY_SUMMARY','Resumen diario');
INSERT INTO billing.plans (id, code, name, price_amount, billing_period_id, trial_days) VALUES
  (1,'TRIAL','Prueba',0,1,30), (2,'BASIC','Básico',35000,1,NULL), (3,'PRO','Pro',65000,1,NULL);
INSERT INTO billing.plan_limits VALUES
  (1,1,30),(1,2,2),(1,3,1), (2,1,100),(2,2,2),(2,3,1), (3,1,NULL),(3,2,NULL),(3,3,NULL);
INSERT INTO billing.plan_features VALUES (1,4), (2,4), (3,1),(3,2),(3,3),(3,4);
INSERT INTO billing.subscription_statuses (id, code, name, allows_writes, is_initial, is_terminal) VALUES
  (1,'TRIAL','Prueba',true,true,false), (2,'ACTIVE','Activa',true,false,false),
  (3,'GRACE','En periodo de gracia',true,false,false), (4,'READ_ONLY','Solo lectura',false,false,false),
  (5,'CANCELLED','Cancelada',false,false,true);
INSERT INTO billing.subscription_status_transitions VALUES
  (1,2),(1,4),(2,3),(3,2),(3,4),(4,2),(1,5),(2,5),(3,5),(4,5);

-- ---------------------------------------------------------------- notificaciones
INSERT INTO notifications.channels (id, code, name, is_enabled) VALUES
  (1,'PUSH','Notificación push',true), (2,'WHATSAPP','WhatsApp',false), (3,'SMS','SMS',false), (4,'EMAIL','Correo',false);
INSERT INTO notifications.notification_types (id, module_id, code, name) VALUES
  (1,4,'PACKAGE_PURCHASED','Compra de tiquetera'), (2,5,'CONSUMPTION_REGISTERED','Consumo registrado'),
  (3,5,'CONSUMPTION_REGISTERED_LATE','Consumo registrado sin internet'), (4,5,'CONSUMPTION_REVERSED','Consumo reversado'),
  (5,4,'RENEWAL_REMINDER','Aviso de renovación'), (6,7,'DAILY_SUMMARY','Resumen diario'),
  (7,9,'SUBSCRIPTION_GRACE','Suscripción en gracia');
INSERT INTO notifications.templates (notification_type_id, channel_id, version, title_template, body_template) VALUES
  (1,1,1,'¡Listo, veci!','{{tenant}} te cargó {{units}} {{unit_plural}}. Ahora tienes {{balance}} disponibles.'),
  (2,1,1,'¡Buen provecho, veci!','{{tenant}} descontó {{units}} {{unit_name}}. Te quedan {{balance}}.'),
  (3,1,1,'Te contamos, veci','{{tenant}} registró tu consumo de {{units}} {{unit_name}} a las {{occurred_time}}. Te llega ahora porque en ese momento no había internet.'),
  (4,1,1,'Corregimos tu saldo','{{tenant}} reversó un consumo de {{units}} {{unit_name}}. Ahora tienes {{balance}}.'),
  (5,1,1,'¡Ojo, veci!','Te quedan {{balance}} {{unit_plural}} en {{tenant}}. Renueva tu tiquetera y sigue tranquilo.'),
  (6,1,1,'Tu día en VECI','Hoy vendiste {{sales_count}} tiqueteras por {{sales_amount}} y se sirvieron {{consumptions}} consumos.'),
  (7,1,1,'Tu plan VECI venció','Tienes {{grace_days_left}} días para renovar. Tus datos siguen seguros con nosotros.');
INSERT INTO notifications.notification_statuses VALUES
  (1,'PENDING','Pendiente',false), (2,'SENT','Enviada',true), (3,'FAILED','Falló',false), (4,'CANCELLED','Cancelada',true);
INSERT INTO notifications.notification_status_transitions VALUES (1,2),(1,3),(3,1),(1,4),(3,4);

-- ---------------------------------------------------------------- cumplimiento y auditoría
INSERT INTO compliance.policy_document_types VALUES
  (1,'DATA_TREATMENT_POLICY','Política de tratamiento de datos'), (2,'TERMS_OF_SERVICE','Términos de uso');
INSERT INTO compliance.consent_channels VALUES
  (1,'SELF_APP','El cliente en la app'), (2,'ASSISTED_BY_CASHIER','Confirmada por el cajero'), (3,'WEB','Web');
INSERT INTO compliance.data_request_types VALUES
  (1,'CONSULTATION','Consulta de datos',10), (2,'CORRECTION','Corrección de datos',15),
  (3,'DELETION','Supresión de datos',15), (4,'CONSENT_REVOCATION','Revocar autorización',15);
INSERT INTO compliance.data_request_statuses (id, code, name, is_initial, is_terminal) VALUES
  (1,'FILED','Radicada',true,false), (2,'IN_PROGRESS','En trámite',false,false),
  (3,'RESOLVED','Resuelta',false,true), (4,'REJECTED','Rechazada',false,true);
INSERT INTO compliance.data_request_status_transitions VALUES (1,2),(2,3),(2,4),(1,4);

INSERT INTO audit.actions (id, module_id, code, name, is_sensitive) VALUES
  (1,1,'LOGIN_LOCKED','Cuenta bloqueada por intentos',true), (2,1,'PIN_RESET','PIN restablecido',true),
  (3,1,'SESSION_REVOKED','Sesión cerrada a distancia',true), (4,2,'TENANT_CREATED','Comercio creado',false),
  (5,2,'MEMBERSHIP_CHANGED','Estado de membresía cambiado',true), (6,2,'ROLE_GRANTED','Rol asignado',true),
  (7,2,'ROLE_REVOKED','Rol retirado',true), (8,3,'CUSTOMER_AFFILIATED','Cliente afiliado',false),
  (9,3,'QR_REVOKED','QR revocado',true), (10,4,'SALE_CREATED','Venta registrada',false),
  (11,4,'SALE_VOIDED','Venta anulada',true), (12,4,'BALANCE_ADJUSTED','Saldo ajustado',true),
  (13,5,'CONSUMPTION_REGISTERED','Consumo registrado',false), (14,5,'CONSUMPTION_REVERSED','Consumo reversado',true),
  (15,5,'EXTRA_CONSUMPTION_AUTHORIZED','Consumo adicional autorizado',true),
  (16,6,'CONFLICT_RESOLVED','Conflicto resuelto',true), (17,2,'SETTING_CHANGED','Configuración cambiada',false),
  (18,9,'SUBSCRIPTION_CHANGED','Suscripción cambiada',false), (19,10,'DATA_REQUEST_RESOLVED','Solicitud de datos resuelta',true),
  (20,10,'PERSON_ANONYMIZED','Datos personales anonimizados',true);
