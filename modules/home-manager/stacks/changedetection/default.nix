{
  config,
  lib,
  ...
}: let
  name = "changedetection";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/dgtlmoon/changedetection.io:latest";
        environment = {
          PLAYWRIGHT_DRIVER_URL = "ws://sockpuppetbrowser:3000";
        };
        volumes = [
          "${storage}:/datastore"
        ];
        port = 5000;
        traefik.name = "changes";
        homepage = {
          category = "Monitoring";
          name = "Changedetection";
          settings = {
            description = "Website change detection and monitoring";
            icon = "changedetection";
          };
        };
        stack = name;
      };
      sockpuppetbrowser = {
        image = "docker.io/dgtlmoon/sockpuppetbrowser:latest";
        stack = name;
      };
    };
  };
}
