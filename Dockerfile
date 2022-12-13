# Define Alpine repo and version
ARG ALPINE_REPO=https://mirror.yandex.ru/mirrors/alpine/
ARG ALPINE_VERSION=3.17
ARG NODE_ENV=production

# Download pnpm ( https://pnpm.io )
FROM alpine:${ALPINE_VERSION} as preliminary
WORKDIR /app
RUN wget -O /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" \
 && chmod +x /bin/pnpm


# Build some node packages
FROM alpine:3.17 as intermediate
WORKDIR /app
ARG ALPINE_REPO
ARG ALPINE_VERSION
ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN echo "${ALPINE_REPO}v${ALPINE_VERSION}/main" > /etc/apk/repositories \
 && echo "${ALPINE_REPO}v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
 && apk add \
    bash \
    cairo-dev \
    g++ \
    jpeg-dev \
    make \
    nodejs \
    pango-dev \
    python3
COPY --from=preliminary /bin/pnpm /bin/pnpm
RUN pnpm add -g node-gyp
COPY ./foxtan/scripts/ ./scripts/
COPY ./foxtan/app/Infrastructure/Config.js ./app/Infrastructure/
COPY ./foxtan/package.json ./foxtan/pnpm-lock.yaml ./
RUN pnpm fetch \
 && pnpm rebuild


# Build dirty image (dev packages, hot reload)
FROM intermediate as development
RUN apk add \
    ffmpeg \
    font-noto
EXPOSE 6749/tcp 9229/tcp
COPY ./docker-entrypoint.dev.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]


# Build clean image
FROM alpine:3.17 as production
WORKDIR /app
ARG ALPINE_REPO
ARG ALPINE_VERSION
ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME
ENV TZ=UTC

RUN echo "${ALPINE_REPO}v${ALPINE_VERSION}/main" > /etc/apk/repositories \
 && echo "${ALPINE_REPO}v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
 && apk add --no-cache \
    bash \
    ffmpeg \
    font-noto \
    jpeg \
    nodejs \
    pango
COPY ./docker-entrypoint.sh /
COPY --from=preliminary /bin/pnpm /bin/pnpm
COPY --from=intermediate $PNPM_HOME/store/ $PNPM_HOME/store/
COPY --from=intermediate /app/node_modules/ ./node_modules/
COPY ./foxtan/package.json ./foxtan/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prefer-offline --ignore-scripts --prod

EXPOSE 6749/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY ./foxtan/ ./config.js ./
