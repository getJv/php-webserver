# https://medium.com/4yousee/infraestrutura-em-ambiente-de-desenvolvimento-com-docker-parte-1-eb28507d5eca
# docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
FROM php:8.0.13-fpm-alpine

MAINTAINER Jhonatan Morais <jhonatanvinicius@gmail.com>

# https://vsupalov.com/docker-shared-permissions/
 ARG USER_ID
 ARG GROUP_ID
 RUN addgroup --system --gid $GROUP_ID dev && \
     adduser --system --disabled-password --gecos '' --uid $USER_ID dev -G dev


RUN apk update --no-cache && \
    apk add \
    icu-dev \
    oniguruma-dev \
    tzdata

# Image Cleaner
RUN rm -rf /var/cache/apk/*

CMD ["php-fpm"]
