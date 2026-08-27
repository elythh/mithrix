{
  config,
  lib,
  ...
}: let
  name = "immich";

  dbName = "${name}-db";
  redisName = "${name}-redis";
  mlName = "${name}-machine-learning";

  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.meadow.stacks.mediaStorageBaseDir}";
  cfg = config.meadow.stacks.${name};

  env = {
    TZ = config.meadow.stacks.defaultTz;
    DB_HOSTNAME = dbName;
    DB_USERNAME = "postgres";
    DB_PASSWORD = "1234";
    DB_DATABASE_NAME = "immich";
    DB_VECTOR_EXTENSION = "vectorchord";
    REDIS_HOSTNAME = redisName;
    NODE_ENV = "production";
  };
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/immich-app/immich-server:release";
        volumes = ["${mediaStorage}/pictures/immich:/usr/src/app/upload"];

        environment = env;

        dependsOn = [redisName dbName];

        traefik = {
          name = name;
          subDomain = "photo";
          middlewares = ["public"];
        };

        port = 2283;

        stack = name;

        homepage = {
          category = "Media";
          name = "Immich";
          settings = {
            description = "Self-hosted photo and video management";
            icon = "immich";
          };
        };
      };

      ${redisName} = {
        image = "docker.io/redis:6.2";
        stack = name;
      };

      ${dbName} = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
        volumes = ["${storage}/pgdata:/var/lib/postgresql/data"];

        environment = {
          POSTGRES_USER = env.DB_USERNAME;
          POSTGRES_PASSWORD = env.DB_PASSWORD;
          POSTGRES_DB = env.DB_DATABASE_NAME;
          DB_STORAGE_TYPE = "HDD";
        };

        stack = name;
      };

      ${mlName} = {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        volumes = ["${storage}/model-cache:/cache"];

        stack = name;
      };
    };
  };
}
