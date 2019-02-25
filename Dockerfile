FROM node:10-alpine AS node
FROM php:7.2-fpm-alpine
MAINTAINER dyoshikawa

# install packages
RUN apk add -U --no-cache \
    bash \
    git \
    curl-dev \
    libxml2-dev \
    postgresql-dev \
    libpng-dev \
    zip \
    unzip

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
    gd \
    zip

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# install composer plugin
RUN composer global require laravel/installer
ENV PATH=~/.composer/vendor/bin:$PATH
RUN composer global require hirak/prestissimo

# add node.js npm
COPY --from=node /usr/local /usr/local
RUN apk add --no-cache python make g++
RUN rm /usr/local/bin/yarn /usr/local/bin/yarnpkg

RUN apk add shadow
RUN useradd -u 1000 -g 1000 dyoshikawa
RUN mkdir /work && chown 1000:1000 -R /work
WORKDIR /work
USER dyoshikawa

ENTRYPOINT []
CMD php artisan serve --host 0.0.0.0
