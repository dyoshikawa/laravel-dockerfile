FROM node:10-alpine AS node
FROM php:7.2-alpine
MAINTAINER dyoshikawa

# install packages
RUN apk add -U --no-cache
              bash \
              git \
              curl-dev \
              libxml2-dev \
              postgresql-dev \
              libpng-dev

# install PHP extensions
RUN docker-php-source extract
RUN cp /usr/src/php/ext/openssl/config0.m4 /usr/src/php/ext/openssl/config.m4
RUN docker-php-ext-install pdo\
                           pdo_mysql \
                           mysqli \
                           pdo_pgsql \
                           pgsql \
                           mbstring \
                           curl \
                           ctype \
                           xml \
                           json \
                           tokenizer \
                           openssl \
                           gd

# install zip, unzip and composer
RUN apk add --no-cache zip unzip \
 && curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer

# install composer plugin
RUN composer global require hirak/prestissimo

# create Laravel project
RUN composer create-project --prefer-dist "laravel/laravel=5.6.*" /myproject
WORKDIR /myproject
RUN composer require predis/predis
RUN composer require barryvdh/laravel-debugbar --dev
RUN composer require squizlabs/php_codesniffer --dev
RUN composer require barryvdh/laravel-ide-helper --dev

# add node.js npm
COPY --from=node /usr/local /usr/local
RUN apk add --no-cache python make g++
RUN rm /usr/local/bin/yarn /usr/local/bin/yarnpkg

CMD php artisan serve --host 0.0.0.0
