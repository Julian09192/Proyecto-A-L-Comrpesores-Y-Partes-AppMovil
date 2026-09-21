# Conexión de la app con la base de datos y servicios

Este documento explica cómo la aplicación conecta con la base de datos y con los servicios del backend, qué puertos usa, y cómo se comporta en web, Android y entorno local.

## 1. Resumen general

La app usa dos capas principales:

1. Supabase como base de datos principal para la lógica de negocio, autenticación y catálogo de productos.
2. Backend HTTP local o remoto para endpoints REST como usuarios, bitácora y notificaciones.

La conexión se inicializa en el arranque de la app desde:

- [lib/main.dart](lib/main.dart)
- [lib/services/supabase/supabase_service.dart](lib/services/supabase/supabase_service.dart)

El flujo típico es:

- El proyecto carga las variables de entorno desde `.env`.
- Inicializa Supabase con `SUPABASE_URL` y `SUPABASE_ANON_KEY`.
- Cada servicio usa Supabase directamente o intenta primero una API HTTP y luego hace fallback a Supabase.

---

## 2. Inicialización de Supabase

La inicialización ocurre en `main()`:

```dart
await dotenv.load(fileName: ".env");
await SupabaseService.initialize();
```

La clase de inicialización lee estas variables del archivo `.env`:

```dart
final String supabaseUrl = dotenv.env['SUPABASE_URL'] ??
    dotenv.env['VITE_SUPABASE_URL'] ??
    '';

final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
    dotenv.env['VITE_SUPABASE_ANON_KEY'] ??
    '';
```

Y luego hace:

```dart
await Supabase.initialize(
  url: supabaseUrl,
  publishableKey: supabaseAnonKey,
);
```

### Variables esperadas

En el archivo `.env` deben existir, al menos:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima
```

También se aceptan nombres alternativos:

```env
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

Si faltan, la app lanza una excepción de configuración.

---

## 3. Servicios que usan Supabase

### 3.1 Productos

Archivo principal:

- [lib/services/products/producto_service.dart](lib/services/products/producto_service.dart)

Usa:

```dart
final SupabaseClient _supabase = Supabase.instance.client;
```

Operaciones principales:

- `getAll()` → consulta a la tabla `productos`
- `getById()` → consulta por id
- `filterByParams()` → filtros por marca, tipo, código y búsqueda
- `crear()` → inserta en `productos`
- `update()` → actualiza registros
- `toggleSuspension()` → cambia `suspendido`

Ejemplo real:

```dart
final data = await _supabase
    .from('productos')
    .select('*')
    .order('id', ascending: false);
```

La tabla que usa la app es `productos`.

### 3.2 Usuarios

Archivo:

- [lib/services/user/usuario_service.dart](lib/services/user/usuario_service.dart)

Este servicio intenta primero la API HTTP y si falla usa Supabase.

Ejemplo de fallback:

```dart
final data = await Supabase.instance.client
    .from('usuario')
    .select('*')
    .order('creado_en', ascending: false);
```

La tabla principal es `usuario`.

### 3.3 Perfil y autenticación

Se usa Supabase Auth directamente desde:

- [lib/screens/Login/login_screen.dart](lib/screens/Login/login_screen.dart)
- [lib/screens/splash/splash_screen.dart](lib/screens/splash/splash_screen.dart)
- [lib/services/user/auth_helper.dart](lib/services/user/auth_helper.dart)

Ejemplos:

```dart
await Supabase.instance.client.auth.signInWithPassword(...);
await Supabase.instance.client.auth.signUp(...);
```

Esto significa que la autenticación vive en Supabase Auth, y la información del usuario se sincroniza con la tabla `usuario`.

### 3.4 Bitácora

Archivo:

- [lib/services/bitacora/bitacora_service.dart](lib/services/bitacora/bitacora_service.dart)

Esta capa hace un intento inteligente:

1. Consulta una API HTTP local en puerto 3001.
2. Si falla, consulta la tabla `bitacora` en Supabase.
3. Si tampoco existe, genera registros a partir de `productos`.

Ejemplo:

```dart
var query = supabase.from('bitacora').select('*');
```

---

## 4. API HTTP local / backend

La app tiene varios servicios que intentan consumir un backend REST antes de caer a Supabase.

### 4.1 Puerto general usado por la app

Se observa en varias capas estas URLs:

- Web: `http://localhost:3001/api/...`
- Android emulador: `http://10.0.2.2:3001/api/...`
- Dispositivo físico Android: se suele usar la IP local del PC, por ejemplo `http://192.168.1.38:3001/api`

### 4.2 Usuarios

En [lib/services/user/usuario_service.dart](lib/services/user/usuario_service.dart):

```dart
static const String baseUrl = 'http://192.168.1.38:3001/api';
```

Endpoints típicos que se usan o se intentan usar:

- `GET /api/usuarios`
- `PUT /api/usuarios/:id`
- `GET /api/usuarios/buscar?query=...`
- `POST /api/usuarios`

### 4.3 Notificaciones

Archivo:

- [lib/services/notificaciones/notificacion_service.dart](lib/services/notificaciones/notificacion_service.dart)

URL base:

```dart
http://localhost:3001/api/notificaciones
```

o en Android:

```dart
http://10.0.2.2:3001/api/notificaciones
```

Endpoints que usa:

- `GET /api/notificaciones`
- `PUT /api/notificaciones/marcar-todas`
- `PUT /api/notificaciones/:id/leer`
- `DELETE /api/notificaciones/:id`

### 4.4 Bitácora

Archivo:

- [lib/services/bitacora/bitacora_service.dart](lib/services/bitacora/bitacora_service.dart)

URL base:

```dart
kIsWeb ? 'http://localhost:3001/api/bitacora' : 'http://10.0.2.2:3001/api/bitacora'
```

Esto es importante porque en web el host es `localhost`, pero en Android emulador se usa `10.0.2.2`.

---

## 5. Diferencia entre web y Android

### Web

Cuando la app corre en navegador, el backend local se accede con `localhost`:

```text
http://localhost:3001
```

### Android emulador

Cuando corre en un emulador Android, `localhost` apunta al emulador mismo, no a tu PC. Por eso se usa:

```text
http://10.0.2.2:3001
```

### Android físico

En un dispositivo real, se debe usar la IP local del equipo donde corre el backend:

```text
http://192.168.1.38:3001
```

Eso explica por qué el proyecto usa variantes de URL según el entorno.

---

## 6. Modelo de conexión real de la aplicación

La lógica general es esta:

```text
Flutter app
   ├── Carga .env
   ├── Inicializa Supabase
   ├── Servicios de datos consultan Supabase
   ├── Servicios de backend consultan API REST en puerto 3001
   └── Si el backend falla, hace fallback a Supabase
```

En pocas palabras:

- Para catálogo, usuario, autenticación y reportes: Supabase.
- Para endpoints transitorios o módulos del backend custom: HTTP local en puerto 3001.
- Para robustez: muchos servicios intentan primero REST y luego usan Supabase como respaldo.

---

## 7. Ejemplos concretos de consulta

### Supabase directo

```dart
await Supabase.instance.client
    .from('productos')
    .select('*')
    .eq('id', id)
    .single();
```

### API REST local

```dart
await http.get(Uri.parse('http://localhost:3001/api/usuarios'));
```

### Fallback inteligente

```dart
try {
  final response = await http.get(Uri.parse(baseUrl));
  // si responde bien, usa API
} catch (e) {
  // si falla, usa Supabase
}
```

---

## 8. Cómo se conecta la BD en la práctica

La base de datos principal es Supabase, y la app se conecta así:

- `Supabase.initialize(url, publishableKey)`: se hace una sola vez.
- En cada servicio: `Supabase.instance.client` devuelve el cliente activo.
- Las tablas se consultan con `.from('nombre_tabla')`.
- Las consultas son tipo:
  - `select('*')`
  - `insert(...)`
  - `update(...)`
  - `eq(...)`
  - `order(...)`
  - `single()`

Ejemplo de tabla crítica:

- `productos`
- `usuario`
- `bitacora`

---

## 9. Recomendaciones para que todo funcione

1. Crea un archivo `.env` en la raíz del proyecto.
2. Define `SUPABASE_URL` y `SUPABASE_ANON_KEY` válidos.
3. Si usas backend local, levanta el servidor en el puerto `3001`.
4. Si ejecutas la app en Android emulador, usa `10.0.2.2` para acceder al backend local.
5. Si ejecutas en dispositivo real, usa la IP local del PC.
6. Verifica que las tablas existan en Supabase exactamente con los nombres que usan los servicios.

---

## 10. Resumen corto

La conexión del proyecto es una mezcla de:

- Supabase: base de datos y autenticación principal.
- API REST local: servicios de usuarios, notificaciones y bitácora.
- Puerto 3001: backend local por defecto.
- `localhost` en web y `10.0.2.2` en emulador Android.
- Fallback: la app intenta REST y si falla usa Supabase.

Si necesitas, en el siguiente paso puedo dejarte también una versión de este documento en formato más técnico para backend o para el equipo de desarrollo.
