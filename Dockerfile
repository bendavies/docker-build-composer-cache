# syntax=docker/dockerfile:1.4

FROM composer:2.2.9 AS composer-base-image
FROM php:8.1-fpm-alpine3.15 AS base-image

FROM base-image AS production-composer-dependencies

WORKDIR /build

RUN  \
    --mount=source=/usr/bin/composer,target=/usr/bin/composer,from=composer-base-image \
    --mount=type=cache,target=/root/.composer,id=composer \
    --mount=source=composer.json,target=composer.json \
    --mount=source=composer.lock,target=composer.lock \
    composer install \
    --no-dev \
    --no-plugins

FROM production-composer-dependencies AS development-composer-dependencies

WORKDIR /build

RUN \
    --mount=source=/usr/bin/composer,target=/usr/bin/composer,from=composer-base-image \
    --mount=type=cache,target=/root/.composer,id=composer \
    --mount=source=composer.json,target=composer.json \
    --mount=source=composer.lock,target=composer.lock \
    composer install \
    --no-plugins

FROM base-image AS base-with-codebase

WORKDIR /app

COPY --link ./src ./src

FROM base-with-codebase AS production

COPY --link ./composer.json \
    ./composer.lock \
    ./

COPY --link --from=production-composer-dependencies /build/vendor vendor

FROM base-with-codebase AS development

COPY --link ./composer.json \
    ./composer.lock \
    ./

COPY --link --from=development-composer-dependencies /build/vendor vendor