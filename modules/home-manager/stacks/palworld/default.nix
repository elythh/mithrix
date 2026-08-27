{
  config,
  lib,
  ...
}: let
  name = "palworld";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Palworld Server";
    };
    serverDescription = lib.mkOption {
      type = lib.types.str;
      default = "A Palworld dedicated server";
    };
    players = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
    adminPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    community = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.templates."palworld/env" = {
      content = ''
        SERVER_PASSWORD=${config.sops.placeholder."palworld/password"}
      '';
    };

    services.podman.containers.${name} = {
      image = "docker.io/thijsvanloef/palworld-server-docker:latest";
      ports = [
        "8211:8211/udp"
        "27015:27015/udp"
      ];
      environment =
        {
          PUID = config.meadow.facts.uid;
          PGID = config.meadow.facts.gid;
          TZ = config.meadow.stacks.defaultTz;
          PORT = "8211";
          PLAYERS = toString cfg.players;
          SERVER_NAME = cfg.serverName;
          SERVER_DESCRIPTION = cfg.serverDescription;
          REST_API_ENABLED = "true";
          REST_API_PORT = "8212";
          COMMUNITY = toString cfg.community;
        }
        // lib.optionalAttrs (cfg.adminPassword != null) {ADMIN_PASSWORD = cfg.adminPassword;};
      environmentFile = [config.sops.templates."palworld/env".path];
      volumes = [
        "${storage}:/palworld"
      ];
    };
  };
}
