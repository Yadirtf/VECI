// Carga backend/.env si existe (desarrollo local). En staging y producción las
// variables llegan del proveedor y este archivo no hace nada. No pisa las ya definidas.
import { existsSync } from 'node:fs';

if (existsSync('.env')) process.loadEnvFile('.env');
