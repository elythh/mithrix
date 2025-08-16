{
  config,
  lib,
  ...
}: let
  name = "aiostreams";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/viren070/aiostreams:latest";
      environmentFile = [config.sops.secrets."aiostreams/env".path];
      volumes = [
        "${storage}/data:/app/data"
      ];
      environment = {
        BASE_URL = "https://${name}.elyth.xyz";
      };

      port = 3000;
      traefik.name = name;
      homepage = {
        category = "Media";
        name = "AIOStreams";
        settings = {
          description = "Stream Source Aggregator";
          icon = "stremio";
        };
      };
    };
  };
}
