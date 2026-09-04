{
  config,
  lib,
  ...
}: let
  name = "palworld";
  dashboardName = "${name}-dashboard";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Server Confidentiel";
    };
    serverDescription = lib.mkOption {
      type = lib.types.str;
      default = "server du discord Confidentiel";
    };
    players = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
    community = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.templates."${name}/env" = {
      content = ''
        SERVER_PASSWORD=${config.sops.placeholder."${name}/password"}
        ADMIN_PASSWORD=${config.sops.placeholder."${name}/password"}
      '';
    };

    sops.templates."${dashboardName}/env" = {
      content = ''
        PANEL_INITIAL_ADMIN_PASSWORD=${config.sops.placeholder."${name}/password"}
        PALWORLD_ADMIN_PASSWORD=${config.sops.placeholder."${name}/password"}
      '';
    };

    services.podman.containers = {
      ${name} = {
        image = "docker.io/thijsvanloef/palworld-server-docker:latest";
        ports = [
          "8211:8211/udp"
          "27015:27015/udp"
        ];
        environment = {
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
        };
        environmentFile = [config.sops.templates."${name}/env".path config.sops.secrets."${name}/env".path];
        volumes = [
          "${storage}:/palworld"
        ];
        stack = name;
      };

      ${dashboardName} = {
        image = "ghcr.io/rnz01/palworld-server-dashboard:latest";
        user = "0:0";
        environment = {
          NODE_ENV = "production";
          PORT = "3000";
          HOSTNAME = "0.0.0.0";
          PALWORLD_REST_URL = "http://${name}:8212";
          PALWORLD_FPS_SAMPLER = "true";
          PALWORLD_FPS_HISTORY_FILE = "/app/data/fps-history.json";
          PALWORLD_PLAYER_ACTIVITY = "true";
          PALWORLD_PLAYER_ACTIVITY_FILE = "/app/data/player-activity.json";
          PANEL_AUTH_FILE = "/app/data/panel-auth.json";
        };
        environmentFile = [config.sops.templates."${dashboardName}/env".path];
        volumes = [
          "${config.meadow.stacks.storageBaseDir}/${dashboardName}:/app/data"
        ];
        port = 3000;
        traefik = {
          name = name;
          middlewares = ["public"];
        };
        stack = name;
        homepage = {
          category = "Games";
          name = "Palworld";
          settings = {
            description = "Palworld Server Dashboard";
            icon = "steam";
          };
        };
      };
    };
  };
}
