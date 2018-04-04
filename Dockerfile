FROM php:7.2-alpine

# install bash
RUN apk -U add bash

# install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli mbstring

# install zip, unzip and composer
RUN apk add zip unzip \
 && curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer

# install composer plugin
RUN composer global require hirak/prestissimo

# create Laravel project
RUN composer create-project --prefer-dist "laravel/laravel=5.6.*" /app
WORKDIR /app
RUN composer require predis/predis \
 && composer require barryvdh/laravel-debugbar --dev

CMD ["php", "artisan", "serve", "--host", "0.0.0.0"]
