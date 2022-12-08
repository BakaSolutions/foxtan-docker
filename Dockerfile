FROM alpine:3.17 as downloader
WORKDIR /app
RUN wget -O /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" \
 && chmod +x /bin/pnpm


FROM alpine:3.17 as builder
WORKDIR /app

ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN echo "https://mirror.yandex.ru/mirrors/alpine/v3.17/main" > /etc/apk/repositories \
 && echo "https://mirror.yandex.ru/mirrors/alpine/v3.17/community" >> /etc/apk/repositories \
 && apk add --no-cache \
    bash \
    build-base \
    cairo-dev \
    jpeg-dev \
    nodejs \
    pango-dev \
    python3
COPY --from=downloader /bin/pnpm /bin/pnpm
RUN pnpm add -g node-gyp knex
COPY ./foxtan/scripts ./scripts
COPY ./foxtan/app/Infrastructure/Config.js ./app/Infrastructure/
COPY ./foxtan/package.json ./foxtan/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile \
 && pnpm remove -g node-gyp \
 && pnpm store prune


FROM alpine:3.17 as production
WORKDIR /app

ENV TZ=UTC
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN echo "https://mirror.yandex.ru/mirrors/alpine/v3.17/main" > /etc/apk/repositories \
 && echo "https://mirror.yandex.ru/mirrors/alpine/v3.17/community" >> /etc/apk/repositories \
 && apk add --no-cache \
    bash \
    ffmpeg \
    font-noto \
    jpeg \
    nodejs \
    pango
COPY ./docker-entrypoint.sh /
COPY --from=downloader /bin/pnpm /bin/pnpm
COPY --from=builder $PNPM_HOME $PNPM_HOME
COPY --from=builder /app/node_modules/ ./node_modules/

EXPOSE 6749/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY ./foxtan/ ./config.js ./
