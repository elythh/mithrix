{
  config,
  lib,
  ...
}: let
  name = "mc-hardcore";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    motd = lib.mkOption {
      type = lib.types.str;
      default = "§4BC §cHardcore §f- §aZEVENT 2027";
    };
    maxPlayers = lib.mkOption {
      type = lib.types.int;
      default = 20;
    };
    memory = lib.mkOption {
      type = lib.types.str;
      default = "6G";
    };
    whitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["eElyth" "BooKyyQLF" "Sami1018"];
      description = "Minecraft usernames/UUIDs allowed to join the server";
    };
    ops = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["Eelyth"];
      description = "Minecraft usernames/UUIDs granted operator permissions";
    };
    icon = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = ../../../../kirk.png;
      description = "Path to an image used as the server icon";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/itzg/minecraft-server:latest";
      ports = [
        "25565:25565/tcp"
      ];
      environment = {
        EULA = "TRUE";
        TYPE = "FABRIC";
        VERSION = "26.1";
        UID = config.meadow.facts.uid;
        GID = config.meadow.facts.gid;
        TZ = config.meadow.stacks.defaultTz;

        MODRINTH_PROJECTS = "soul-link-speedrun, fabric-api";

        DIFFICULTY = "hard";
        MODE = "survival";
        ONLINE_MODE = "TRUE";
        MOTD = cfg.motd;
        MAX_PLAYERS = toString cfg.maxPlayers;
        MEMORY = cfg.memory;

        ENABLE_WHITELIST = "true";
        OVERRIDE_WHITELIST = "true";
        WHITELIST = builtins.concatStringsSep "," cfg.whitelist;
        OPS = builtins.concatStringsSep "," cfg.ops;
      }
      // lib.optionalAttrs (cfg.icon != null) {
        ICON = "/config/server-icon.png";
        OVERRIDE_ICON = "true";
      };
      volumes =
        [
          "${storage}/data:/data"
        ]
        ++ lib.optionals (cfg.icon != null) [
          "${cfg.icon}:/config/server-icon.png:ro"
        ];
      homepage = {
        category = "Games";
        name = "MC Hardcore";
        settings = {
          description = "Soul Link co-op speedrun Minecraft server";
          icon = "minecraft";
        };
      };
    };
  };
}
