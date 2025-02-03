#!/bin/sh

# Optimisation Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Migrations
php artisan migrate --force

# Démarrage des services
php-fpm -D && nginx -g 'daemon off;' 