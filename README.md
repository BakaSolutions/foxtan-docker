# foxtan container for Docker

Since foxtan is not capable to work on Windows platforms due to `sharp` and `canvas` 
[incompability issue](https://github.com/Automattic/node-canvas/issues/930), it was decided to dockerize the engine.

### Installation
```shell
git clone https://github.com/BakaSolutions/foxtan-docker foxtan && cd foxtan
git submodule init && git submodule update
cp .env.template .env
```

### Startup

#### Production
For Linux/BSD: `./start.sh`

For Windows: `.\start.bat`

#### Development
For Linux/BSD: `./start.dev.sh`

For Windows: `.\start.dev.bat`

### Update dependencies

#### Pnpm
Docker caches layers that have not been modified in the Dockerfile.
In this file the link always points to the latest version of [pnpm](https://pnpm.io).
Sometimes it is necessary to update the `preliminary` layer by clearing the cache.
To do this, run the following command:
```shell
docker build . --target preliminary --no-cache
```
