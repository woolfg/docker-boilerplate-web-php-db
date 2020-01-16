FROM php:7-fpm-alpine
RUN docker-php-ext-install mysqli

COPY src /www
RUN chown www-data:www-data -R /www