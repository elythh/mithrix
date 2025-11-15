
{
  config,
  lib,
  ...
}: let
  name = "ephemera";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/orwellianepilogue/ephemera:latest";
      volumes = [
        "${storage}/data:/app/data"
        "${storage}/downloads:/app/downloads"
        "${storage}/ingest:/app/ingest"
      ];
      traefik = {
        name = name;
        middlewares = ["public"];
      };
      port = 8286;
      environmentFile = [config.sops.secrets."ephemera/env".path];
      homepage = {
        category = "Media";
        name = "ephemera";
        settings = {
          description = "Book Downloader";
          icon = "ephemera";
        };
      };
      stack = name;
    };
    services.podman.containers.flaresolverr1 = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        stack = name;
    };
  };
}
