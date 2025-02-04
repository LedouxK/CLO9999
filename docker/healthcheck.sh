#!/bin/bash
set -e

# Fonction pour vérifier un service
check_service() {
    if ! pgrep -x "$1" > /dev/null; then
        echo "❌ Service $1 non actif"
        exit 1
    fi
}

# Vérification des processus
check_service "php-fpm"
check_service "nginx"

# Vérification de Nginx
if ! curl -s -f http://localhost:8080/health > /dev/null; then
    echo "❌ Endpoint /health non accessible"
    exit 1
fi

# Vérification de PHP via FastCGI
SCRIPT_NAME=/health \
SCRIPT_FILENAME=/var/www/html/public/health \
REQUEST_METHOD=GET \
cgi-fcgi -bind -connect 127.0.0.1:9000 > /dev/null 2>&1 || {
    echo "❌ PHP-FPM ne répond pas"
    exit 1
}

# Vérification de la connexion à la base de données
if ! php artisan db:monitor > /dev/null 2>&1; then
    echo "❌ Base de données non accessible"
    exit 1
fi

# Vérification de l'utilisation mémoire
memory_usage=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
if [ "$memory_usage" -gt 90 ]; then
    echo "❌ Utilisation mémoire critique: ${memory_usage}%"
    exit 1
fi

# Vérification de l'espace disque
disk_usage=$(df -h / | awk 'NR==2 {print int($5)}')
if [ "$disk_usage" -gt 90 ]; then
    echo "❌ Espace disque critique: ${disk_usage}%"
    exit 1
fi

echo "✅ Container en bonne santé"
exit 0 