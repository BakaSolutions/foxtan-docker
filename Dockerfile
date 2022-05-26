FROM node:slim
WORKDIR /app

# For apt:
RUN apt update
RUN apt install -y git
RUN apt install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
RUN apt install -y python3
RUN apt install -y ffmpeg

# For apk:
# RUN apk add --no-cache nodejs npm
# RUN apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-devbash imagemagick
# RUN apk add --no-cache python
# RUN apk add --no-cache ffmpeg
# RUN npm i -g node-gyp

COPY ./foxtan/ ./.dockerignore ./config.js ./
ENV NODE_ENV=production
RUN npm install
EXPOSE 6749
CMD ["npm", "start"]
