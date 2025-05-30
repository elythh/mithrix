{
  lib,
  config,
  pkgs,
  ...
}: let
  name = "traefik";
  cfg = config.tarow.stacks.${name};

  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
in {
  imports = [
    ./extension.nix
  ];

  options.tarow.stacks.${name} = {
    enable = lib.options.mkEnableOption name;
    domain = lib.options.mkOption {
      type = lib.types.str;
      description = "Base domain handled by Traefik";
    };
    network = lib.options.mkOption {
      type = lib.types.str;
      description = "Network for the Traefik docker provider";
      default = "traefik-proxy";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.networks.${cfg.network} = {
      driver = "bridge";
      extraPodmanArgs = [
      ];
    };

    services.podman.containers.${name} = {
      image = "traefik:v3";

      socketActivation = [
        {
          port = 80;
          fileDescriptorName = "web";
        }
        {
          port = 443;
          fileDescriptorName = "websecure";
        }
      ];
      ports = [
        #"443:443"
        #"80:80"
      ];
      environmentFile = [config.sops.secrets."traefik/env".path];
      volumes = [
        "${storage}/letsencrypt:/letsencrypt"
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
        "${pkgs.writeText "traefik.yml" (import ./config/traefik.nix {inherit (cfg) domain;})}:/etc/traefik/traefik.yml:ro"
        "${./config/dynamic.yml}:/dynamic/config.yml"
        "${./config/IP2LOCATION-LITE-DB1.IPV6.BIN}:/plugins/geoblock/IP2LOCATION-LITE-DB1.IPV6.BIN"
      ];
      labels = lib.mkForce {
        "traefik.enable" = "true";
        "traefik.http.routers.api.entrypoints" = "websecure";
        "traefik.http.routers.api.rule" = ''Host(\`${name}.${cfg.domain}\`)'';
        "traefik.http.routers.api.middlewares" = "private-chain@file";
        "traefik.http.routers.api.service" = "api@internal";
      };
      network = [cfg.network];
    };
  };
}
