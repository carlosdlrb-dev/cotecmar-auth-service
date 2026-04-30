#!/usr/bin/env sh
set -eu

cd /var/www/html

if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

if [ "${APP_KEY:-}" = "" ] || [ "${APP_KEY:-}" = "base64:" ]; then
  php artisan key:generate --force >/dev/null
fi

if [ "${JWT_SECRET:-}" = "" ]; then
  php artisan jwt:secret --force >/dev/null
fi

mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache || true

php artisan migrate --force

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8000}"
