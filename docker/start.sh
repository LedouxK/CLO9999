#!/bin/sh

# Attendre que MySQL soit prêt
echo "Waiting for MySQL to be ready..."
while ! php artisan db:monitor 2>/dev/null; do
    sleep 1
done

# Optimisations Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Créer le lien symbolique storage si nécessaire
php artisan storage:link

# Migrations
php artisan migrate --force

# Démarrage des services
php-fpm -D
nginx -g 'daemon off;' 