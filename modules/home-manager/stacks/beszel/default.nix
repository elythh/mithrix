{
  config,
  lib,
  ...
}: let
  name = "beszel";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

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
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      environment = {
        LISTEN = "45876";
      };
      environmentFile = [config.sops.secrets."beszel/env".path];
      stack = name;
    };
  };
}
