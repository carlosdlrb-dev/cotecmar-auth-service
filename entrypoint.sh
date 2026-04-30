#!/bin/bash
set -e

php artisan migrate --seed --force

apache2-foreground
