{
  config,
  lib,
  ...
}: let
  name = "aiometadata";
  redisName = "${name}-redis";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/cedya77/aiometadata:latest";
        stack = name;
        dependsOn = [redisName];
        extraConfig.Container.RunInit = true;
        volumes = [
          "${storage}/data:/app/addon/data"
        ];
        environment = {
          NODE_ENV = "production";
          PORT = "3232";
          HOST_NAME = "https://${name}.elyth.xyz";
          DATABASE_URI = "sqlite://addon/data/db.sqlite";
          REDIS_URL = "redis://${redisName}:6379";
        };

        port = 3232;
        traefik.name = name;
        homepage = {
          category = "Media";
          name = "AIOMetadata";
          settings = {
            description = "Stremio metadata aggregator";
            icon = "stremio";
          };
        };
      };

      ${redisName} = {
        image = "docker.io/redis:latest";
        stack = name;
        exec = "redis-server --appendonly yes --save 3600 1";
        volumes = [
          "${storage}/cache:/data"
        ];
      };
    };
  };
}
