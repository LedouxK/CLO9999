# Utilisez une image Docker officielle pour PHP avec Apache
FROM php:8.2-apache

# Installez les dépendances système et les extensions PHP nécessaires
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install pdo_mysql zip gd

# Activez les modules Apache nécessaires pour .htaccess
RUN a2enmod rewrite negotiation headers

# Installez Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurez Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Configurez le virtual host avec les options nécessaires pour .htaccess
RUN sed -i 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's!Listen 80!Listen 8080!g' /etc/apache2/ports.conf \
    && sed -i 's!<VirtualHost \*:80>!<VirtualHost *:8080>!g' /etc/apache2/sites-available/000-default.conf

# Ajoutez la configuration du répertoire avec les options appropriées
RUN echo '<Directory ${APACHE_DOCUMENT_ROOT}>\n\
    Options -MultiViews -Indexes\n\
    AllowOverride All\n\
    Require all granted\n\
    <IfModule mod_rewrite.c>\n\
        RewriteEngine On\n\
        RewriteCond %{HTTP:Authorization} .\n\
        RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]\n\
    </IfModule>\n\
</Directory>' >> /etc/apache2/sites-available/000-default.conf

# Définissez le répertoire de travail
WORKDIR /var/www/html

# Copiez les fichiers de composer d'abord
COPY composer.json composer.lock ./

# Installez les dépendances
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copiez le reste des fichiers de l'application
COPY . .

# Créez le fichier .env et générez la clé
COPY .env.production .env
RUN php artisan key:generate --force

# Optimisez Laravel
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan storage:link

# Ajustez les permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

CMD ["apache2-foreground"]