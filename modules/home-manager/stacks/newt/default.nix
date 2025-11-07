{
  config,
  lib,
  ...
}: let
  name = "newt";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/fosrl/newt:latest";
      environmentFile = [config.sops.secrets."newt/env".path];
      homepage = {
        category = "Utilities";
        name = "newt";
        settings = {
          description = "Tunnel";
          icon = "newt";
        };
      };
    };
  };
}
