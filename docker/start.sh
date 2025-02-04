#!/bin/bash
set -e

echo "🚀 Démarrage de l'application..."

# Fonction de nettoyage en cas d'erreur
cleanup() {
    echo "❌ Une erreur est survenue. Nettoyage..."
    # Arrêt des services
    pkill -f php-fpm || true
    pkill -f nginx || true
    exit 1
}

# Capture des erreurs
trap cleanup ERR

# Vérification des variables d'environnement essentielles
required_env_vars=(
    "APP_KEY"
    "DB_HOST"
    "DB_DATABASE"
    "DB_USERNAME"
    "DB_PASSWORD"
)

for var in "${required_env_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Erreur: Variable d'environnement $var non définie"
        exit 1
    fi
done

echo "✅ Variables d'environnement vérifiées"

# Création des répertoires nécessaires
mkdir -p /run/php /var/www/html/storage/logs
chown -R www-data:www-data /run/php /var/www/html/storage

# Vérification de la connexion à la base de données
max_tries=30
count=0

echo "🔄 Attente de la base de données..."
while ! php artisan db:monitor > /dev/null 2>&1; do
    echo "⏳ Tentative $((count+1))/$max_tries..."
    sleep 2
    count=$((count+1))
    if [ $count -ge $max_tries ]; then
        echo "❌ Impossible de se connecter à la base de données après $max_tries tentatives"
        exit 1
    fi
done

echo "✅ Connexion à la base de données établie"

# Optimisations Laravel
echo "🔄 Optimisation de Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan storage:link || true

# Migrations avec backup automatique
echo "🔄 Exécution des migrations..."
if ! php artisan migrate --force; then
    echo "❌ Erreur pendant les migrations"
    exit 1
fi

echo "✅ Migrations terminées"

# Démarrage de PHP-FPM
echo "🔄 Démarrage de PHP-FPM..."
php-fpm -D
sleep 2
if ! pgrep php-fpm > /dev/null; then
    echo "❌ Erreur: PHP-FPM n'a pas démarré"
    exit 1
fi

echo "✅ PHP-FPM démarré"

# Vérification de la configuration Nginx
echo "🔄 Vérification de la configuration Nginx..."
nginx -t
if [ $? -ne 0 ]; then
    echo "❌ Erreur dans la configuration Nginx"
    exit 1
fi

echo "✅ Configuration Nginx validée"

# Création du fichier robots933456.txt pour Azure s'il n'existe pas
if [ ! -f /var/www/html/public/robots933456.txt ]; then
    echo "User-agent: *\nDisallow: /" > /var/www/html/public/robots933456.txt
fi

# Démarrage de Nginx
echo "🚀 Démarrage de Nginx..."
exec nginx -g 'daemon off;' 