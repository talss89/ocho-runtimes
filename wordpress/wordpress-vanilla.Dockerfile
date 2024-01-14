ARG WORDPRESS_VERSION=6.4.2
FROM bedrock
ARG WORDPRESS_VERSION
ENV WORDPRESS_VERSION=${WORDPRESS_VERSION}
ENV WP_CONTENT_DIR=${DOCUMENT_ROOT}/wp-content
ENV STACK_MEDIA_PATH=/wp-content/uploads
RUN set -ex \
    && wp core download --skip-content --path=web/wp --version=${WORDPRESS_VERSION} \
    && cp /usr/local/docker/webroot/* /app/web/
ONBUILD COPY --chown=www-data:www-data config /app/config
ONBUILD COPY --chown=www-data:www-data wp-content /app/web/wp-content
