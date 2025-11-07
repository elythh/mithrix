{
  config,
  lib,
  ...
}: let
  name = "golink";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/tailscale/golink:latest";
      environmentFile = [config.sops.secrets."golink/env".path];
      # volumes = [
      #   "${storage}/data:/home/nonroot"
      # ];
      homepage = {
        category = "Utilities";
        name = "golink";
        settings = {
          description = "Tailscale linker";
          icon = "stremio";
        };
      };
    };
  };
}
