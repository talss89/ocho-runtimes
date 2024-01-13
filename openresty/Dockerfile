ARG WWW_DATA_UID=888
ARG WWW_DATA_GID=888
ARG OPENRESTY_VERSION=1.25.3.1-0
FROM openresty/openresty:${OPENRESTY_VERSION}-alpine-apk as openresty
ARG WWW_DATA_UID
ARG WWW_DATA_GID

COPY ./common/docker/build-scripts /usr/local/docker/build-scripts/

ENV PATH="/usr/local/docker/bin:${PATH}"
ENV PORT=8080
ENV DOCUMENT_ROOT=/app/web

RUN 

RUN set -ex \
    && apk add --no-cache curl shadow \
    && /usr/local/docker/build-scripts/install-envtmpl 

WORKDIR /app

RUN set -ex \
    && groupmod -g ${WWW_DATA_GID} www-data \
    && adduser -S -D -u ${WWW_DATA_UID} -s /sbin/nologin -h /var/www -G www-data www-data\
    && mkdir /app/html \
    && { \
       echo "Welcome to openresty"; \
    } | tee /app/html/index.php >&2

COPY ./common/docker /usr/local/docker
COPY ./openresty/docker /usr/local/docker
COPY ./openresty/nginx-lua /usr/local/docker/lib/nginx/lua/

ENTRYPOINT ["/usr/local/docker/bin/docker-entrypoint"]
CMD ["/usr/local/docker/etc/start-nginx.sh"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT