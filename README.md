## Auth Service (Laravel) — PRUEBA COTECMAR

Servicio de autenticación para la arquitectura mínima de microservicios solicitada en la prueba técnica. Expone una API REST que valida credenciales y emite un **token JWT** para que otros servicios (p. ej. Pieces Service) y el Frontend consuman endpoints protegidos.

### Stack

- **Backend**: Laravel (requiere PHP 8.4+). En este repo se usa **Laravel 11**.
- **Auth**: JWT con `php-open-source-saver/jwt-auth`.
- **Persistencia**: Migraciones + Eloquent (tabla `users`).

### Endpoints principales

Base URL (local): `http://localhost:8000`

#### `POST /api/login`

Valida `email` y `password`. Si las credenciales son correctas, genera un JWT.

- **Body (JSON)**:

```json
{
  "email": "user@example.com",
  "password": "secret"
}
```

- **200 OK (JSON)**:

```json
{
  "token": "<jwt>",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": { }
}
```

- **401 Unauthorized (JSON)**:

```json
{
  "message": "Invalid credentials."
}
```

Ejemplo:

```bash
curl -X POST "http://localhost:8000/api/login" -H "Content-Type: application/json" -d "{\"email\":\"user@example.com\",\"password\":\"secret\"}"
```

#### `GET /api/me` (protegido)

Devuelve el usuario autenticado.

- **Header**: `Authorization: Bearer <token>`
- **200 OK (JSON)**:

```json
{
  "user": { }
}
```

Ejemplo:

```bash
curl "http://localhost:8000/api/me" -H "Authorization: Bearer <token>"
```

#### `POST /api/logout` (protegido)

Hace logout del usuario (invalida el token con blacklist si está habilitado).

- **Header**: `Authorization: Bearer <token>`
- **200 OK (JSON)**:

```json
{
  "message": "Logged out successfully."
}
```

Ejemplo:

```bash
curl -X POST "http://localhost:8000/api/logout" -H "Authorization: Bearer <token>"
```

### Variables de entorno

Este servicio requiere las variables típicas de Laravel (ver `.env.example`) y además variables para JWT:

- **Laravel**
  - `APP_KEY`: se genera con `php artisan key:generate`
  - `APP_URL`: URL base del servicio (ej. `http://localhost:8000`)
  - `DB_CONNECTION`: usar `mysql` con los datos de conexión correspondientes
- **JWT**
  - `JWT_SECRET`: se genera con `php artisan jwt:secret`
  - `JWT_TTL`: minutos de validez del token (default 60)
  - `JWT_ALGO`: algoritmo de firmado (default `HS256`)
  - (Opcionales) `JWT_REFRESH_TTL`, `JWT_BLACKLIST_ENABLED`, etc. (ver `config/jwt.php`)

### Pasos de ejecución (local)

Requisitos: **PHP 8.4+**, Composer.

1) Instalar dependencias:

```bash
composer install
```

2) Crear `.env` desde ejemplo:

```bash
copy .env.example .env
```

En PowerShell también puedes usar:

```powershell
Copy-Item .env.example .env
```

3) Generar claves:

```bash
php artisan key:generate
php artisan jwt:secret
```

4) Base de datos y migraciones:

Asegúrate de tener una base de datos MySQL creada y configuradas las variables `DB_*` en `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=auth_service
DB_USERNAME=root
DB_PASSWORD=
```

Luego corre las migraciones junto con el seeder:

```bash
php artisan migrate --seed
```

Esto creará las tablas y el usuario de prueba:

| Campo    | Valor              |
|----------|--------------------|
| Email    | demo@example.com   |
| Password | secret123          |

5) Levantar el servicio:

```bash
php artisan serve
```

### Ejecución con Docker

Requisito: **Docker Desktop**.

#### Levantar los contenedores

```bash
docker compose up -d --build
```

Esto levanta dos servicios:

| Servicio | Descripción | Puerto |
|---|---|---|
| `auth-service` | Aplicación Laravel + Apache | `8000` |
| `auth-mysql` | Base de datos MySQL 8 | `3307` (host) |

Al iniciar, el contenedor ejecuta automáticamente `php artisan migrate --seed` y crea el usuario de demo.

#### Comandos útiles

```bash
# Ver logs en tiempo real
docker logs -f auth-service

# Acceder al contenedor
docker exec -it auth-service bash

# Correr migraciones manualmente
docker exec auth-service php artisan migrate

# Detener los contenedores
docker compose down

# Detener y eliminar volúmenes (borra la base de datos)
docker compose down -v
```

### Decisiones técnicas

- **JWT como mecanismo de autenticación**: se usa `auth:api` con driver `jwt` para cumplir el requerimiento de API protegida por token entre microservicios.
- **Validación y errores**: `POST /api/login` valida formato (`email`) y retorna **401** con mensaje cuando las credenciales son inválidas.
- **Eloquent + migraciones**: el modelo `User` y la migración `create_users_table` soportan el flujo de autenticación sin acoplarse a otros servicios.
