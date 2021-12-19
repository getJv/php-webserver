# https://medium.com/4yousee/infraestrutura-em-ambiente-de-desenvolvimento-com-docker-parte-1-eb28507d5eca
# docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
FROM php:8.0.13-fpm-alpine

MAINTAINER Jhonatan Morais <jhonatanvinicius@gmail.com>

# https://vsupalov.com/docker-shared-permissions/
 ARG USER_ID
 ARG GROUP_ID
 RUN addgroup --system --gid $GROUP_ID dev && \
     adduser --system --disabled-password --gecos '' --uid $USER_ID dev -G dev

# my stuffs
RUN apk --no-cache --update --virtual add  \
    icu-dev \
    oniguruma-dev \
    tzdata \
    nano \
    wget \
    unzip \
    libzip-dev

RUN docker-php-ext-install \ 
    mysqli \
    pdo_mysql 
    
# install xdebug, make sure to choose the desired start_with_request option
# https://stackoverflow.com/questions/31583646/cannot-find-autoconf-please-check-your-autoconf-installation-xampp-in-centos
RUN apk  --no-cache --update --virtual add \
    autoconf g++ make \ 
    && yes | pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=VSCODE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "#choose only one mode and comment the other" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "# Start only when the param XDEBUG_TRIGGER is present on POST, GET or COOKIE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "#xdebug.start_with_request=trigger" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "# Start debug on each request" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && touch /tmp/xdebug.log \
    && chown dev:www-data /tmp/xdebug.log \
    && chmod 775 /tmp/xdebug.log \
    && rm -rf /tmp/pear; apk del autoconf g++ make;

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Image Cleaner
RUN rm -rf /var/cache/apk/*


#Laravel Installation
ENV ENV="/home/dev/.ashrc"
USER dev
RUN composer global require laravel/installer 
RUN	echo 'alias laravel="~/.composer/vendor/bin/laravel"' >> /home/dev/.ashrc 

CMD ["php-fpm"]
