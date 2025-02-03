# Image de base PHP 8.2 avec FPM
FROM php:8.2-fpm

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration de Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
RUN rm -rf /etc/nginx/sites-enabled/* && \
    rm -rf /etc/nginx/sites-available/*

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers de composer
COPY composer.json composer.lock ./

# Installer les dépendances
RUN composer install --no-scripts --no-autoloader --no-dev

# Copier le reste des fichiers de l'application
COPY . .

# Créer le fichier .env à partir de .env.example
COPY .env.example .env

# Générer la clé d'application
RUN php artisan key:generate

# Optimisations finales
RUN composer dump-autoload --optimize && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 storage bootstrap/cache

# Script de démarrage
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080

CMD ["/usr/local/bin/start.sh"]