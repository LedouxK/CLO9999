#!/bin/bash
set -e

# Démarrage de PHP-FPM en arrière-plan
php-fpm -D

# Démarrage de Nginx en premier plan
nginx -g 'daemon off;' 