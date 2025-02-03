#!/bin/bash

# Aller dans le répertoire du projet
cd /home/site/wwwroot

# Installation des dépendances
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Permissions
chmod -R 777 storage bootstrap/cache

# Optimisations Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Migrations (si nécessaire)
php artisan migrate --force

# Nettoyage
php artisan cache:clear
php artisan config:clear 