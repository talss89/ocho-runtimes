FROM php

ARG WP_CLI_VERSION=2.9.0
ENV WP_CLI_VERSION=${WP_CLI_VERSION}
ENV WP_CLI_CONFIG_PATH=/app/wp-cli.yml
ENV DOCUMENT_ROOT=/app/web
ENV WP_CONTENT_DIR=${DOCUMENT_ROOT}/app
ENV STACK_MEDIA_PATH=/app/uploads
USER root
COPY ./common/docker/build-scripts /usr/local/docker/build-scripts/
COPY ./wordpress/docker/build-scripts /usr/local/docker/build-scripts/
RUN set -ex \
    && /usr/local/docker/build-scripts/install-wp-cli \
    && rm -rf /app \
    && mkdir -p /app/web /src \
    && { \
       echo "path: $DOCUMENT_ROOT/wp"; \
    } | tee /app/wp-cli.yml >&2 \
    && chown -R www-data:www-data /app /src

COPY --chown=www-data:www-data ./common/docker /usr/local/docker
COPY --chown=www-data:www-data ./wordpress/docker /usr/local/docker
USER www-data
