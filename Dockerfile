# docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
ARG PHP_VERSION=8.2.5

FROM php:${PHP_VERSION}-fpm-alpine

MAINTAINER Jhonatan Morais <jhonatanvinicius@gmail.com>

# Copy builder user to mac system as dev
ARG USER_ID
ARG GROUP_ID
RUN echo "dev:x:$USER_ID:$USER_ID::/home/dev:" >> /etc/passwd && \
    echo "dev:!:$(($(date +%s) / 60 / 60 / 24)):0:99999:7:::" >> /etc/shadow  && \
    echo "dev:x:$USER_ID:" >> /etc/group  && \
    mkdir /home/dev && chown dev: /home/dev

# essencial stuffs
RUN apk --no-cache --update add  \
    $PHPIZE_DEPS \
    libzip-dev \
    libxml2-dev \
    oniguruma-dev \
    acl \
    fcgi \
    git \
    nano \
    wget \
    unzip \
    bash \
    nodejs \
    npm

RUN docker-php-ext-install  mysqli pdo_mysql \
    && docker-php-ext-enable mysqli pdo_mysql

# Add composer manager
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install Symfony
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# add Session Path PHP
RUN mkdir /var/lib/php \
    && mkdir /var/lib/php/sessions \
    && mkdir /var/lib/php/sessions/dev \
    && chown -R dev:www-data /var/lib/php \
    && chmod -R 775 /var/lib/php/sessions/dev

# install xdebug, make sure to choose the desired start_with_request option
RUN apk  --no-cache --update --virtual add \
    autoconf g++ make linux-headers \
    && yes | pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "#Set next param as 'trigger' to debug only when the param XDEBUG_TRIGGER be present on POST, GET or COOKIE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && touch /tmp/xdebug.log \
    && chown dev:www-data /tmp/xdebug.log \
    && chmod 775 /tmp/xdebug.log \
    && rm -rf /tmp/pear; apk del autoconf g++ make;


# add extras features
# RUN apk --no-cache add file  zip openssh

# install pack to work with timezone, intl, encode and set LD_PRELOAD env to make iconv work fully on Alpine image.
RUN apk add --no-cache icu-dev gnu-libiconv gettext tzdata \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

# Enable php to do complex math operations
#RUN docker-php-ext-install bcmath \
#    && docker-php-ext-enable bcmath

# enable work with redis
RUN pecl install redis \
    && docker-php-ext-enable redis.so

# enable work with rabbitmq
RUN apk add --no-cache rabbitmq-c-dev \
    && pecl install amqp \
    && docker-php-ext-enable amqp

# enable work with soap
#RUN docker-php-ext-install  soap \
#    && docker-php-ext-enable soap

# Install dependencies for GD and install GD with support for jpeg, png webp and freetype
# Info about installing GD in PHP https://www.php.net/manual/en/image.installation.php
#RUN apk add --no-cache \
#        libjpeg-turbo-dev \
#        libpng-dev \
#        libwebp-dev \
#        freetype-dev \
#  && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
#  && docker-php-ext-install gd

# Image Cleaner
RUN rm -rf /var/cache/apk/*

ENV ENV="/home/dev/.ashrc"
USER dev
CMD ["php-fpm"]
