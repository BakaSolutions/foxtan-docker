# foxtan container for Docker

Since foxtan is not capable to work on Windows platforms due to `sharp` and `canvas` incompability,
it was decided to dockerize the engine.

### Installation instructions
```bash
$ git -v
$ docker -v
$ docker-compose -v
$ git clone https://github.com/BakaSolutions/foxtan.git foxtan && cd foxtan
$ git submodule init && git submodule update
$ git submodule foreach npm install
$ docker-compose up --build -d
```