{
  config,
  lib,
  ...
}: let
  name = "beszel";
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/henrygd/beszel:latest";
      volumes = [
        "${storage}/data:/beszel_data"
      ];
      port = 8090;
      traefik.name = name;
      stack = name;
    };
    services.podman.containers."${name}-agent" = {
      image = "docker.io/henrygd/beszel-agent:latest";
      volumes = [
        "${config.meadow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      environment = {
        LISTEN = "45876";
        LOG_LEVEL = "debug";
      };
      environmentFile = [config.sops.secrets."beszel/env".path];
      stack = name;
    };
  };
}
