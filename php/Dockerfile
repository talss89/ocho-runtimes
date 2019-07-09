ARG PHP_VERSION=7.3.6
FROM php:${PHP_VERSION}-fpm-stretch as php
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG FLAVOUR=minimal

ENV PATH="/usr/local/docker/bin:${PATH}"
ENV PHP_VERSION=${PHP_VERSION}
ENV FLAVOUR=${FLAVOUR}
ENV COMPOSER_VERSION=1.8.6
ENV SUPERVISORD_VERSION=0.6.3
ENV DOCKERIZE_VERSION=1.2.0
ENV RCLONE_VERSION=1.48.0
# https://github.com/grpc/grpc/issues/13412
ENV GRPC_ENABLE_FORK_SUPPORT=1
ENV GRPC_POLL_STRATEGY=epoll1
# keep wp-cli happy
ENV PAGER=cat

# configure composer
ENV COMPOSER_CACHE_DIR=/tmp/composer/.cache
ENV COMPOSER_HOME=/tmp/composer
ENV COMPOSER_NO_INTERACTION=1

# install openresty and minimal requirements
RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y gnupg=2.1* \
    && curl -s https://openresty.org/package/pubkey.gpg | apt-key add - \
    && echo "deb http://openresty.org/package/debian stretch openresty" > /etc/apt/sources.list.d/openresty.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ssmtp=2.64* unzip=6.0* openresty=1.13* libyaml-0-2=0.1* libyaml-dev=0.1* \
        less=481* git=1:2.11* openssh-client=1:7.4* procps \
    # we need yaml support for installing extensions
    && pecl install yaml \
    && docker-php-ext-enable --ini-name 50-docker-php-ext-yaml.ini yaml \
    && apt-get autoremove --purge -y libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

COPY docker/build-scripts /usr/local/docker/build-scripts/

RUN set -ex \
    && apt-get update \
    && mkdir -p ${COMPOSER_HOME} ${COMPOSER_CACHE_DIR} \
    && chown www-data:www-data ${COMPOSER_HOME} ${COMPOSER_CACHE_DIR} \
    && chmod 777 ${COMPOSER_HOME} ${COMPOSER_CACHE_DIR} \
    && /usr/local/docker/build-scripts/install-composer \
    && composer global require --prefer-dist hirak/prestissimo 0.3.9 \
    && /usr/local/docker/build-scripts/install-rclone \
    && /usr/local/docker/build-scripts/install-dockerize \
    && /usr/local/docker/build-scripts/install-supervisord \
    && /usr/local/docker/build-scripts/install-php-extensions /usr/local/docker/build-scripts/php-extensions.${FLAVOUR}.yaml \
    && rm -rf /var/lib/apt/lists/* /tmp/pear/* ${COMPOSER_CACHE_DIR:?}/*

WORKDIR /app
# prepare rootfs
RUN set -ex \
    # symlink generated php.ini
    && ln -sf /usr/local/docker/etc/php.ini /usr/local/etc/php/conf.d/zz-01-custom.ini \
    # symlink php.ini from /app/config/php.ini
    && ln -sf /app/config/php.ini /usr/local/etc/php/conf.d/zz-90-app.ini \
    # our dummy index
    && mkdir /app/html \
    && { \
       echo "<?php phpinfo(); "; \
    } | tee /app/html/index.php >&2 \
    && mkdir -p /var/lib/nginx/logs \
    && ln -sf /dev/null /var/lib/nginx/logs/error.log \
    && chown -R www-data:www-data /app \
    && chown -R www-data:www-data /run \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /var/www

COPY --chown=www-data:www-data ./docker /usr/local/docker
COPY --chown=www-data:www-data ./nginx-lua /usr/local/docker/lib/nginx/lua/
USER www-data:www-data

EXPOSE 8080
ENTRYPOINT ["/usr/local/docker/bin/docker-php-entrypoint"]
CMD ["supervisord", "-c", "/usr/local/docker/etc/supervisor.conf"]