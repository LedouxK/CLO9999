# Utilisez une image Docker officielle pour PHP avec Apache
FROM php:8.2-apache

# Installez les extensions PHP et outils nécessaires
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    default-mysql-client \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Installez Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurez Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# Copiez les fichiers de l'application
WORKDIR /var/www/html
COPY . .

# Créez le fichier .env
COPY .env.example .env

# Installez les dépendances et optimisez
RUN composer install --no-dev --optimize-autoloader \
    && php artisan key:generate \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Configuration pour Azure App Service
RUN echo "Listen 8080" >> /etc/apache2/ports.conf \
    && sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf \
    && sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf

# Exposez le port 8080 pour Azure
EXPOSE 8080

# Script de démarrage pour les migrations
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]