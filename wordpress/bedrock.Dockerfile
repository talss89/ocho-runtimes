FROM php AS base

ARG WP_CLI_VERSION=2.9.0
ENV WP_CLI_VERSION=${WP_CLI_VERSION}
ENV WP_CLI_CONFIG_PATH=/app/wp-cli.yml
ENV DOCUMENT_ROOT=/app/web
ENV WP_CONTENT_DIR=${DOCUMENT_ROOT}/app
ENV STACK_MEDIA_PATH=/app/uploads
ENV NODE_ENV=production

USER root
COPY ./common/docker/build-scripts /usr/local/docker/build-scripts/
COPY ./wordpress/docker/build-scripts /usr/local/docker/build-scripts/
RUN set -ex \
    && /usr/local/docker/build-scripts/install-wp-cli \
    && rm -rf /app \
    && mkdir -p /app/web/app /src \
    && { \
    echo "path: $DOCUMENT_ROOT/wp"; \
    } | tee /app/wp-cli.yml >&2 \
    && chown -R www-data:www-data /app /src

COPY --chown=www-data:www-data ./common/docker /usr/local/docker
COPY --chown=www-data:www-data ./wordpress/docker /usr/local/docker
USER www-data

FROM base as dev
ARG NODE_VERSION=20
USER root
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    screen \
    ca-certificates \
    curl \
    git \
    ;\
    rm -rf /var/lib/apt/lists/* /var/cache/*;
RUN chsh -s /bin/bash www-data
USER www-data
ENV NODE_ENV=development
RUN mkdir /var/www/.ssh
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV ~/.bashrc
ENV VOLTA_HOME /var/www/.volta
ENV PATH $VOLTA_HOME/bin:$PATH
RUN curl https://get.volta.sh | bash && volta install node@${NODE_VERSION}
COPY --chown=www-data:www-data ./wordpress/docker-dev /usr/local/docker