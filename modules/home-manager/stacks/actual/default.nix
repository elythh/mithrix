{
  config,
  lib,
  ...
}: let
  name = "actual";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/actualbudget/actual:latest";
      volumes = [ "${storage}/data:/app/data" ];
      port = 5006;
      traefik.name = "budget";
      homepage = {
        category = "Utilities";
        name = "Actual";
        settings = {
          description = "Budget Manager";
          icon = "Actual";
        };
      };
    };
  };
}
