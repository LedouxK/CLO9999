# Image de base PHP-FPM
FROM php:8.2-fpm

# Installation des dépendances système et extensions PHP
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    unzip \
    libpng-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install pdo_mysql zip gd

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration de Nginx
COPY docker/nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Définition du répertoire de travail
WORKDIR /var/www/html

# Copie des fichiers de composer
COPY composer.json composer.lock ./

# Installation des dépendances
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copie des fichiers de l'application
COPY . .

# Configuration de l'environnement
COPY .env.production .env
RUN php artisan key:generate --force

# Optimisation de Laravel
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan storage:link

# Ajustement des permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Script de démarrage
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]