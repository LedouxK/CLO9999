# Utilisez une image Docker officielle pour PHP avec Apache
FROM php:8.2-apache

# Installez les extensions PHP nécessaires
RUN docker-php-ext-install pdo_mysql

# Installez les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    && docker-php-ext-install gd

# Installez Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurez Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# Configurez le port pour Azure
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/*.conf /etc/apache2/ports.conf

# Copiez les fichiers de l'application
WORKDIR /var/www/html
COPY . .

# Installez les dépendances
RUN composer install --no-dev --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

CMD ["apache2-foreground"]