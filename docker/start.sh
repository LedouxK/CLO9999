#!/bin/sh
set -e

# Attendre que MySQL soit prêt
echo "Waiting for MySQL to be ready..."
max_tries=30
count=0
while ! mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for MySQL to be ready... ($count/$max_tries)"
    sleep 2
    count=$((count + 1))
    if [ $count -gt $max_tries ]; then
        echo "Error: MySQL did not become ready in time"
        exit 1
    fi
done

echo "MySQL is ready"

# Optimisations Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Créer le lien symbolique storage si nécessaire
php artisan storage:link || true

# Migrations
php artisan migrate --force

# Démarrage des services
php-fpm -D
exec nginx -g 'daemon off;' 