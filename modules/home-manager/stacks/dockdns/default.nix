{
  config,
  lib,
  ...
}: let
  name = "dockdns";
  cfg = config.meadow.stacks.${name};
in {
  imports = [./extension.nix];

  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    sops.templates."dockdns_config.yaml".content = import ./config.nix config;

    services.podman.containers.${name} = {
      image = "ghcr.io/meadow/dockdns:latest";
      volumes = [
        "${config.sops.templates."dockdns_config.yaml".path}:/app/config.yaml"
        "${config.meadow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];

      port = 8080;
      traefik.name = name;
      homepage = {
        category = "Utilities";
        name = "dockdns";
        settings = {
          description = "DNS Updater";
          icon = "azure-dns";
        };
      };
    };
  };
}
