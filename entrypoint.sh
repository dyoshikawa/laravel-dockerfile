#!/bin/sh
chown nginx:nginx -R /app
nginx
php-fpm -F