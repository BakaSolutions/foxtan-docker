const DEBUG = +process.env.DEBUG || false;
let EXTERNAL_URL = process.env.FOXTAN_EXTERNAL_URL || 'http://foxtan';
const DB_URL = process.env.FOXTAN_DB_URL || 'postgresql://root@foxtan-db:5432/foxtantest';
const REDIS_URL = process.env.FOXTAN_REDIS_URL || 'redis://foxtan-redis:6379/0';

const protoScheme = EXTERNAL_URL.startsWith('https://')
  ? 's://'
  : '://';
EXTERNAL_URL = EXTERNAL_URL.replace(/https?:\/\//, '');

let config = {
  debug: {
    enable: DEBUG
  },
  db: {
    type: 'pg',
    pg: {
      url: DB_URL
    },
    redis: {
      url: REDIS_URL
    }
  },
  paths: {
    upload: `http${protoScheme}${EXTERNAL_URL}/src/`,
    thumb: `http${protoScheme}${EXTERNAL_URL}/src/thumb/`,
    ws: `ws${protoScheme}${EXTERNAL_URL}/ws`
  },
};

module.exports = config;
