# Define Alpine repo and version
ARG ALPINE_REPO=https://mirror.yandex.ru/mirrors/alpine/ \
    ALPINE_VERSION=3.17 \
    NODE_ENV=production

# Download pnpm ( https://pnpm.io )
FROM alpine:${ALPINE_VERSION} as preliminary
WORKDIR /app
RUN wget -O /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" \
 && chmod +x /bin/pnpm
# TODO: Fetch common packages, install them and drop cache


# Build some node packages
FROM alpine:${ALPINE_VERSION} as intermediate
WORKDIR /app
ARG ALPINE_REPO \
    ALPINE_VERSION \
    NODE_ENV
ENV NODE_ENV=$NODE_ENV \
    PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN echo "${ALPINE_REPO}v${ALPINE_VERSION}/main" > /etc/apk/repositories \
 && echo "${ALPINE_REPO}v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
 && apk add --no-cache \
    bash \
    cairo-dev \
    ffmpeg \
    font-noto \
    g++ \
    jpeg-dev \
    make \
    nodejs \
    pango-dev \
    python3 \
    vips \
    vips-poppler
COPY --from=preliminary /bin/pnpm /bin/pnpm
RUN pnpm add -g node-gyp
COPY ./foxtan/scripts/postinstall.js ./scripts/
COPY ./foxtan/app/Infrastructure/Config.js ./app/Infrastructure/
COPY ./foxtan/package.json ./foxtan/pnpm-lock.yaml ./
RUN pnpm fetch \
 && pnpm rebuild


# Build dirty image (dev packages, hot reload)
FROM intermediate as development
EXPOSE 6749/tcp 9229/tcp
COPY ./docker-entrypoint.dev.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]


# Build clean image
FROM alpine:${ALPINE_VERSION} as production
WORKDIR /app
ARG ALPINE_REPO \
    ALPINE_VERSION \
    NODE_ENV
ENV NODE_ENV=$NODE_ENV \
    TZ=UTC \
    PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN echo "${ALPINE_REPO}v${ALPINE_VERSION}/main" > /etc/apk/repositories \
 && echo "${ALPINE_REPO}v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
 && apk add --no-cache \
    bash \
    ffmpeg \
    font-noto \
    jpeg \
    nodejs \
    pango \
    vips \
    vips-poppler
EXPOSE 6749/tcp
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
COPY --from=preliminary /bin/pnpm /bin/pnpm
COPY --from=intermediate $PNPM_HOME/store/ $PNPM_HOME/store/
COPY --from=intermediate /app/node_modules/ ./node_modules/
COPY ./foxtan/package.json ./foxtan/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --offline --ignore-scripts --prod
COPY ./foxtan/ ./config.js ./
