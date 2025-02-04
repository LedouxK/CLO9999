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
    curl \
    && docker-php-ext-install pdo_mysql zip gd

# Configuration de PHP-FPM
RUN echo "pm = dynamic\n\
pm.max_children = 10\n\
pm.start_servers = 2\n\
pm.min_spare_servers = 1\n\
pm.max_spare_servers = 3\n\
pm.max_requests = 500\n\
request_terminate_timeout = 300\n\
catch_workers_output = yes" > /usr/local/etc/php-fpm.d/www.conf

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
    && chmod -R 775 storage bootstrap/cache \
    && mkdir -p /run/php \
    && chown www-data:www-data /run/php

# Création du fichier robots933456.txt pour Azure
RUN echo "User-agent: *\nDisallow: /" > /var/www/html/public/robots933456.txt

# Script de démarrage et healthcheck
COPY docker/start.sh /start.sh
COPY docker/healthcheck.sh /healthcheck.sh
RUN chmod +x /start.sh /healthcheck.sh

# Configuration du healthcheck Docker
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /healthcheck.sh

EXPOSE 8080

CMD ["/start.sh"]