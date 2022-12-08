# TODO: pre-build `node-canvas`, remove `*-dev`, `node-gyp` and `python` from build

FROM alpine:3.17
WORKDIR /app

ENV TZ=UTC
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN wget -O /bin/pnpm "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" \
 && chmod +x /bin/pnpm \
 && echo "https://mirror.yandex.ru/mirrors/alpine/v3.17/main" > /etc/apk/repositories \
 && echo "https://mirror.yandex.ru/mirrors/alpine/v3.17/community" >> /etc/apk/repositories \
 && apk add --no-cache nodejs \
    bash build-base cairo-dev jpeg-dev pango-dev font-noto \
    python3 \
    ffmpeg \
 && pnpm add -g node-gyp knex

COPY ./docker-entrypoint.sh /
COPY ./foxtan/scripts ./scripts
COPY ./foxtan/app/Infrastructure/Config.js ./app/Infrastructure/
COPY ./foxtan/package.json ./foxtan/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

EXPOSE 6749/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY ./foxtan/ ./config.js ./
