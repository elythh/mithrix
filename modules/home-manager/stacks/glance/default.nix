{
  config,
  lib,
  ...
}: let
  name = "glance";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/glanceapp/glance:latest";
      volumes = [
        "${storage}/config:/app/config"
      ];
      traefik.name = "dash";
      port = 8080;
      homepage = {
        category = "Utilities";
        name = "glance";
        settings = {
          description = "Home dashboard";
          icon = "glance";
        };
      };
    };
  };
}
