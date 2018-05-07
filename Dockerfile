FROM php:7.2-alpine
MAINTAINER dyoshikawa

# install packages
RUN apk add -U --no-cache bash curl-dev libxml2-dev postgresql-dev

# install PHP extensions
RUN docker-php-source extract
RUN cp /usr/src/php/ext/openssl/config0.m4 /usr/src/php/ext/openssl/config.m4
RUN docker-php-ext-install pdo pdo_mysql mysqli pdo_pgsql pgsql mbstring curl \
                           ctype xml json tokenizer openssl

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
 && composer require barryvdh/laravel-debugbar --dev \
 && composer require squizlabs/php_codesniffer --dev
RUN echo ".idea/" >> .gitignore

CMD ["php", "artisan", "serve", "--host", "0.0.0.0"]
