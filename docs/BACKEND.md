# Arquitectura y Endurecimiento del Backend de JavaPlay

Este documento detalla la arquitectura, configuración, variables de entorno, mecanismos de seguridad y códigos de respuesta HTTP del servidor backend (`backend/server.js`) de JavaPlay.

---

## 1. Arquitectura General

El backend está desarrollado en **Node.js** utilizando módulos nativos (`http`, `https`, `crypto`, `fs`, `path`) y el driver de base de datos PostgreSQL (`pg`).

### Principio de Cero Dependencias Adicionales
No se añadieron dependencias externas adicionales (como Express o librerías pesadas de middleware) para mantener una superficie de ataque mínima, un arranque ultra-rápido en entornos como Azure App Service / Render, y compatibilidad directa sin fricción de versiones.

### Modos de Base de Datos
1. **Modo PostgreSQL (Producción / Supabase / Azure)**: Se activa automáticamente si `DATABASE_URL` o `DB_HOST` está definida. Inicializa el esquema relacional (`schema.sql`) de manera idempotente.
2. **Modo memDb (Desarrollo local / Fallback)**: Se activa automáticamente si no hay credenciales de base de datos configuradas. Mantiene el estado en memoria (`memDb`) permitiendo probar todos los endpoints y el flujo completo sin requerir infraestructura externa.

---

## 2. Variables de Entorno

El servidor carga variables de entorno mediante un parser nativo zero-dependency desde el archivo `.env` en `backend/` si existe, o desde las variables del entorno del sistema operativo / contenedor.

| Variable | Tipo | Obligatoria | Valor por defecto | Descripción |
|---|---|---|---|---|
| `PORT` | Entero | No | `8080` | Puerto TCP en el que escucha el servidor HTTP. |
| `DATABASE_URL` | String | No | `""` | Cadena de conexión PostgreSQL (URI completa, ej. Supabase / Neon / Azure). |
| `DB_HOST` | String | No | `""` | Host alternativo de PostgreSQL si no se usa URI. |
| `DB_PORT` | Entero | No | `5432` | Puerto de PostgreSQL. |
| `DB_USER` | String | No | `""` | Usuario de PostgreSQL. |
| `DB_PASSWORD` | String | No | `""` | Contraseña de PostgreSQL. |
| `DB_NAME` | String | No | `"postgres"` | Nombre de la base de datos. |
| `GEMINI_API_KEY` | String | No | `""` | Clave API de Google AI Studio para evaluar entrevistas simuladas con Gemini 1.5 Flash. Si no está configurada, el backend utiliza su motor semántico experto local de rúbricas. |
| `ALLOWED_ORIGINS` | String | No | `http://localhost:8080,http://127.0.0.1:8080,http://localhost:3000,https://javaplay-app.azurewebsites.net` | Lista separada por comas de orígenes permitidos por la política CORS del navegador. |

---

## 3. Endurecimiento y Reglas de Seguridad

### 3.1 Identificador de Usuario (`userId`)
- **Generación en la App**: Cada instalación de la aplicación móvil genera un UUID v4 criptográficamente seguro al primer arranque, persistido en `SharedPreferences` bajo la clave `app_user_id`.
- **Validación en Backend**:
  - Acepta formato estricto UUID v4 (`/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i`).
  - Permite temporalmente identificadores alfanuméricos heredados (`/^[A-Za-z0-9_-]{3,64}$/`) para garantizar retrocompatibilidad con versiones instaladas durante la transición.
  - *TODO de deuda técnica*: Endurecer a exclusivamente UUID v4 una vez completada la migración de usuarios activos.

### 3.2 Límite de Tamaño de Body (100 KB)
- Límite global: `MAX_BODY_SIZE = 100 * 1024` bytes (100 KB).
- Si el header `Content-Length` o el flujo de datos acumulado excede los 100 KB, el socket se destruye de inmediato y el servidor responde con **HTTP 413 Payload Too Large**.

### 3.3 Rate Limiting en Memoria con Ventana Deslizante
El rate limiting se evalúa en memoria mediante registros temporales por clave:
- **/api/mock/evaluate**:
  - Máximo **10 peticiones / hora** por `userId`.
  - Máximo **30 peticiones / hora** por `IP`.
- **Resto de la API (`/api/*`)**:
  - Máximo **300 peticiones / minuto** por `IP`.
- **Soporte de Proxies (Azure / Render / CDN)**: La función `getClientIp(req)` extrae la IP cliente real tomando el primer valor del encabezado `X-Forwarded-For`.
- **Respuesta 429**: Cuando se excede el límite, el servidor responde con **HTTP 429 Too Many Requests** e incluye la cabecera estándar `Retry-After: <segundos_restantes>`.
- **Limpieza periódica**: Un temporizador no bloqueante (`unref()`) purga entradas inactivas cada 10 minutos para evitar fugas de memoria.

### 3.4 Política CORS
- Se reemplazó el comodín inseguro `*` por una verificación estricta de origen contra `ALLOWED_ORIGINS`.
- **Peticiones sin `Origin`**: Las peticiones de la aplicación móvil Flutter nativa o herramientas backend/curl no envían encabezado `Origin` y son procesadas normalmente.
- **Preflight `OPTIONS`**:
  - Origen en lista permitida: responde **HTTP 204 No Content** con cabeceras `Access-Control-Allow-Origin: <origin>` y `Vary: Origin`.
  - Origen no autorizado: responde **HTTP 403 Forbidden**.

### 3.5 Validación Estricta de Cargas Útiles (Payloads)
Todos los endpoints POST validan tipos, rangos y extensiones antes de interactuar con la base de datos o el estado en memoria:
- `POST /api/progress/:userId`: `xpDelta` (entero 0 a 1000), `lives` (entero 0 a 5), `streak` (entero >= 0).
- `POST /api/srs/:userId/review`: `quality` (entero 0 a 5 según algoritmo SM-2), `exerciseId` (string 1 a 64 caracteres).
- `POST /api/mock/evaluate`: `transcript` (string de máx. 3000 caracteres), `questionId` (string existente en el catálogo), `durationSeconds` (entero 0 a 3600).
- `POST /api/boss/:userId`: `worldId` (string 1 a 64), `bossId` (string 1 a 64), `score` (entero 0 a 100), `xpAwarded` (entero 0 a 1000).

### 3.6 Privacidad y Registro de Logs
- **No se registran transcripciones**: El texto completo de respuestas del usuario (`transcript`) jamás se imprime en `stdout` ni `stderr`.
- **Enmascaramiento de `userId`**: Se dispone de la función `maskUserId(userId)` (ej. `a1b2...e5f6`) para cualquier trazabilidad técnica, evitando exponer identificadores personales en logs del sistema.
- **Protección de Credenciales**: Ni en el arranque ni en `/api/health` se imprimen cadenas de conexión, hosts, usuarios o contraseñas.

### 3.7 Manejo Global de Errores
- Toda la ejecución de `http.createServer` está protegida por un bloque `try/catch` de alto nivel.
- En caso de excepción imprevista, el servidor responde con **HTTP 500 Internal Server Error** con un mensaje genérico JSON y jamás devuelve stack traces, nombres de rutas del servidor o consultas SQL.
- Se capturan `uncaughtException` y `unhandledRejection` a nivel de proceso Node.js para prevenir caídas silenciosas.

---

## 4. Endpoint `/api/health`

Permite a los balanceadores de carga y sondas de salud (health probes) verificar el estado del servicio:

```http
GET /api/health
```

**Respuesta Exitosa (200 OK):**
```json
{
  "status": "UP",
  "service": "JavaPlay Backend API",
  "mode": "PostgreSQL",
  "database": "PostgreSQL",
  "timestamp": "2026-10-17T01:00:00.000Z"
}
```
*(Si se ejecuta localmente sin base de datos, `mode` y `database` reportan `"memDb"`).*

---

## 5. Códigos de Respuesta HTTP

| Código | Significado | Escenario de uso |
|---|---|---|
| **200 OK** | Éxito | Consultas y actualizaciones procesadas correctamente. |
| **204 No Content** | Sin Contenido | Respuestas exitosas a preflight CORS (`OPTIONS`). |
| **400 Bad Request** | Petición Inválida | Parámetros o `userId` malformados, valores fuera de rango, JSON corrupto o preguntas no encontradas. |
| **403 Forbidden** | Prohibido | Petición web desde un origen no autorizado en `ALLOWED_ORIGINS`. |
| **404 Not Found** | No Encontrado | Endpoint o ruta no registrada. |
| **413 Payload Too Large** | Cuerpo Excesivo | Cuerpo de la petición superior al límite de 100 KB. |
| **429 Too Many Requests** | Límite Excedido | Límite de tasa por IP o por usuario sobrepasado. Incluye `Retry-After`. |
| **500 Internal Server Error** | Error del Servidor | Error no capturado. Devuelve respuesta genérica sin detalles internos. |
