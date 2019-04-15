FROM node:10-alpine AS node
FROM php:7.3-fpm-alpine
MAINTAINER dyoshikawa

# install packages
RUN apk add -U --no-cache \
    bash \
    git \
    curl-dev \
    libxml2-dev \
    postgresql-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    zip \
    libzip-dev \
    unzip \
    gmp-dev

# install PHP extensions
RUN docker-php-source extract
RUN cp /usr/src/php/ext/openssl/config0.m4 /usr/src/php/ext/openssl/config.m4
RUN docker-php-ext-configure gd --with-png-dir=/usr/include --with-jpeg-dir=/usr/include
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
    zip \
    gmp \
    bcmath

# install php-ast
RUN apk add --no-cache gcc g++ make autoconf
RUN git clone https://github.com/nikic/php-ast.git \
    && cd php-ast \
    && phpize \
    && ./configure \
    && make install \
    && echo 'extension=ast.so' > /usr/local/etc/php/php.ini \
    && cd .. && rm -rf php-ast

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# install composer plugin
RUN composer global require laravel/installer
ENV PATH=~/.composer/vendor/bin:$PATH
RUN composer global require hirak/prestissimo

# install dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# add node.js npm
COPY --from=node /usr/local /usr/local
RUN apk add --no-cache python make g++
RUN rm /usr/local/bin/yarn /usr/local/bin/yarnpkg

# add user
RUN apk add sudo shadow
RUN groupadd -g 1000 dyoshikawa
RUN useradd -u 1000 -g 1000 dyoshikawa
RUN sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' \
    -i /etc/sudoers
RUN sed -e 's/^wheel:\(.*\)/wheel:\1,dyoshikawa/g' -i /etc/group
RUN mkdir /home/dyoshikawa && chown 1000:1000 -R /home/dyoshikawa
RUN mkdir /work && chown 1000:1000 -R /work
WORKDIR /work
USER dyoshikawa

ENTRYPOINT []
CMD php artisan serve --host 0.0.0.0
