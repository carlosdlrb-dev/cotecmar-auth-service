FROM php:8.2-cli

WORKDIR /var/www/html

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libzip-dev \
    sqlite3 \
  && docker-php-ext-install -j$(nproc) pdo pdo_sqlite zip \
  && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./
RUN composer install --no-interaction --no-progress --prefer-dist --optimize-autoloader

COPY . .

RUN chmod +x /var/www/html/docker/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/var/www/html/docker/entrypoint.sh"]
