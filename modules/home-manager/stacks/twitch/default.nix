{
  config,
  lib,
  ...
}: let
  name = "twitch";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/elythh/dogshit:latest";
        traefik = {
          name = name;
          subDomain = "twitch";
          middlewares = ["public"];
        };
        port = 80;
      };
    };
  };
}
