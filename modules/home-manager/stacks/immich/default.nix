{
  config,
  lib,
  ...
}: let
  name = "immich";

  dbName = "${name}-db";
  redisName = "${name}-redis";
  mlName = "${name}-machine-learning";

  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";
  cfg = config.tarow.stacks.${name};

  env = {
    TZ = config.tarow.stacks.defaultTz;
    DB_HOSTNAME = dbName;
    DB_USERNAME = "postgres";
    DB_PASSWORD = "1234";
    DB_DATABASE_NAME = "immich";
    REDIS_HOSTNAME = redisName;
    NODE_ENV = "production";
  };
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/immich-app/immich-server:release";
        volumes = ["${mediaStorage}/pictures/immich:/usr/src/app/upload"];

        environment = env;

        dependsOn = [redisName dbName];

        traefik.name = name;
        port = 2283;

        stack = name;
      };

      ${redisName} = {
        image = "docker.io/redis:6.2";
        stack = name;
      };

      ${dbName} = {
        image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0";
        volumes = ["${storage}/pgdata:/var/lib/postgresql/data"];

        environment = {
          POSTGRES_USER = env.DB_USERNAME;
          POSTGRES_PASSWORD = env.DB_PASSWORD;
          POSTGRES_DB = env.DB_DATABASE_NAME;
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
