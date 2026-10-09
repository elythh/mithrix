{
  config,
  lib,
  ...
}: let
  name = "dice";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/elythh/dead-mans-dice:latest";
      traefik = {
        name = name;
        subDomain = "dice";
        middlewares = ["public"];
      };
      port = 8080;
      homepage = {
        category = "Games";
        name = "Dead Man's Dice";
        settings = {
          description = "Multiplayer Liar's Dice";
          icon = "dice";
        };
      };
    };
  };
}
