ARG PHP_VERSION=8.2.10
ARG WWW_DATA_UID=888
ARG WWW_DATA_GID=888
FROM php:${PHP_VERSION}-fpm-bullseye as php-ext-build
ARG WWW_DATA_UID
ARG WWW_DATA_GID
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PATH="/usr/local/docker/bin:${PATH}"
ENV PHP_VERSION=${PHP_VERSION}
ENV PORT=8080
ENV DOCUMENT_ROOT=/app/web

ENV COMPOSER_VERSION=2.5.5
# keep wp-cli happy
ENV PAGER=cat

# workaround for https://github.com/docker-library/php/issues/924
ENV PHP_OPENSSL=yes

# configure composer
ENV COMPOSER_CACHE_DIR=/var/lib/composer/cache
ENV COMPOSER_HOME=/var/lib/composer
ENV COMPOSER_NO_INTERACTION=1

RUN set -ex \
    && usermod -u ${WWW_DATA_UID} www-data\
    && groupmod -g ${WWW_DATA_GID} www-data

COPY --chown=www-data:www-data ./common/docker/build-scripts /usr/local/docker/build-scripts/

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        unzip libyaml-0-2 libyaml-dev \
        less git openssh-client procps libmagickwand-dev \
    # we need yaml support for installing extensions
    && pecl install yaml \
    && docker-php-ext-enable --ini-name 50-docker-php-ext-yaml.ini yaml \
    && mkdir -p ${COMPOSER_HOME} ${COMPOSER_CACHE_DIR} \
    && chown www-data:www-data ${COMPOSER_HOME} ${COMPOSER_CACHE_DIR} \
    && chmod 777 ${COMPOSER_HOME} ${COMPOSER_CACHE_DIR} \
    && /usr/local/docker/build-scripts/install-composer \
    && /usr/local/docker/build-scripts/install-envtmpl \
    && /usr/local/docker/build-scripts/install-php-extensions /usr/local/docker/build-scripts/php-extensions.minimal.yaml \
    && apt-get autoremove --purge -y libyaml-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/pear/* ${COMPOSER_CACHE_DIR:?}/* /usr/lib/gcc

RUN set -eux; \
    find /usr/local/lib/php /usr/local/bin /usr/local/sbin -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u > /PACKAGES

FROM debian:bullseye-slim
ENV PATH="/usr/local/docker/bin:${PATH}"
ENV COMPOSER_VERSION=2.5.5
# keep wp-cli happy
ENV PAGER=cat

# workaround for https://github.com/docker-library/php/issues/924
ENV PHP_OPENSSL=yes

COPY --from=php-ext-build /usr/local/include/ /usr/local/include/
COPY --from=php-ext-build /usr/local/lib/php/ /usr/local/lib/php/
COPY --from=php-ext-build /usr/local/bin /usr/local/bin
COPY --from=php-ext-build /usr/local/sbin /usr/local/sbin
COPY --from=php-ext-build /usr/local/etc /usr/local/etc
COPY --from=php-ext-build --chown=www-data:www-data /usr/local/docker /usr/local/docker
COPY --from=php-ext-build /etc/passwd /etc/passwd
COPY --from=php-ext-build /etc/group /etc/group
COPY --from=php-ext-build /etc/shadow /etc/shadow
COPY --from=php-ext-build /PACKAGES /

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    $(cat /PACKAGES) \
    ca-certificates \
    libyaml-0-2 \
    procps \
    msmtp \
    curl \
    less\
    git\
    openssh-client\
    ;\
    rm -rf /var/lib/apt/lists/* /var/cache/*

WORKDIR /app
# prepare rootfs
RUN set -ex \
    # symlink generated php.ini
    && ln -sf /usr/local/docker/etc/php.ini /usr/local/etc/php/conf.d/zz-01-custom.ini \
    # symlink php.ini from /app/config/php.ini
    && ln -sf /app/config/php.ini /usr/local/etc/php/conf.d/zz-90-app.ini \
    # our dummy index
    && mkdir /app/web \
    && { \
       echo "<?php phpinfo(); "; \
    } | tee /app/web/index.php >&2 \
    && mkdir -p /var/lib/nginx/logs \
    && ln -sf /dev/null /var/lib/nginx/logs/error.log \
    && chown -R www-data:www-data /app \
    && chown -R www-data:www-data /run \
    && chown -R www-data:www-data /var/lib/nginx \
    && mkdir /var/www \
    && chown -R www-data:www-data /var/www

COPY --chown=www-data:www-data ./common/docker /usr/local/docker
COPY --chown=www-data:www-data ./php/docker /usr/local/docker

USER www-data:www-data

STOPSIGNAL SIGTERM
EXPOSE 8080
ENTRYPOINT ["/usr/local/docker/bin/docker-entrypoint"]
CMD ["/usr/local/docker/etc/start-php-fpm.sh"]
