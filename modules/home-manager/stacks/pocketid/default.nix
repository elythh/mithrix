{
  config,
  lib,
  ...
}: let
  name = "pocketid";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/pocket-id/pocket-id";
      volumes = ["${storage}/pocketid:/app/data"];
      environmentFile = [config.sops.secrets."pocketid/env".path];
      port = 1411;
      traefik = {
        name = name;
        subDomain = "auth";
        middlewares = ["public"];
      };
      homepage = {
        category = "Utilities";
        name = "pocketid";
        settings = {
          description = "OIDC Provider";
          icon = "pocketid";
        };
      };
    };
  };
}
