{
  config,
  lib,
  ...
}: let
  name = "aiomanager";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/sonicx161/aiomanager:latest";
      stack = name;
      volumes = [
        "${storage}/data:/app/data"
      ];
      environment = {
        NODE_ENV = "production";
        PORT = "1610";
        DATA_DIR = "/app/data";
        DB_TYPE = "sqlite";
      };

      port = 1610;
      traefik.name = name;
      homepage = {
        category = "Media";
        name = "AIOManager";
        settings = {
          description = "Stremio account and addon manager";
          icon = "stremio";
        };
      };
    };
  };
}
