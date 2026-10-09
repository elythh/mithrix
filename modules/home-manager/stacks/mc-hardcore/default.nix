{
  config,
  lib,
  pkgs,
  ...
}: let
  name = "mc-hardcore";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";

  proxyName = "mc-hardcore-proxy";
  serverIds = ["1" "2"];
  containerName = id: "mc-hardcore-${id}";
  velocityName = id: "hardcore${id}";
  containerNames = map containerName serverIds;

  forwardingSecretPath = config.sops.secrets."minecraft/forwarding-secret".path;

  lobbyName = "mc-hardcore-lobby";

  # Files synced into the lobby's /data by the itzg image (COPY_CONFIG_SRC ->
  # COPY_CONFIG_DEST). The velocity secret is interpolated at runtime from
  # ${CFG_VELOCITY_SECRET} so it never ends up in the nix store.
  lobbyConfig = pkgs.runCommand "mc-hardcore-lobby-config" {} ''
    mkdir -p $out/config $out/plugins/Crqzys_Server_Selector
    cp ${pkgs.writeText "paper-global.yml" ''
      proxies:
        velocity:
          enabled: true
          online-mode: false
          secret: '${"$"}{CFG_VELOCITY_SECRET}'
    ''} $out/config/paper-global.yml
    cp ${pkgs.writeText "selector-config.yml" ''
      compass:
        material: COMPASS
        name: "&6&lServer Selector"
        lore:
          - "&7Right-click to choose a hardcore run"
        slot: 4
        droppable: false

      gui:
        title: "&8&lChoose a Server"
        size: 27
        fill-border: true

      servers:
        hardcore1:
          material: DIAMOND_SWORD
          name: "&b&lHardcore 1"
          lore:
            - "&7Soul Link run #1"
          id: hardcore1
          slot: 11
        hardcore2:
          material: IRON_SWORD
          name: "&a&lHardcore 2"
          lore:
            - "&7Soul Link run #2"
          id: hardcore2
          slot: 13
    ''} $out/plugins/Crqzys_Server_Selector/config.yml
  '';

  velocityToml = pkgs.writeText "velocity.toml" ''
    config-version = "2.9"
    bind = "0.0.0.0:25577"
    motd = "BC Hardcore Network"
    show-max-players = ${toString cfg.maxPlayers}
    online-mode = true
    force-key-authentication = true
    prevent-client-proxy-connections = false
    player-info-forwarding-mode = "modern"
    forwarding-secret-file = "forwarding.secret"
    announce-forge = false
    enable-player-address-logging = true

    [servers]
    lobby = "${lobbyName}:25565"
    ${lib.concatStringsSep "\n" (map (id: "${velocityName id} = \"${containerName id}:25565\"") serverIds)}

    try = ["lobby"]

    # Must be declared explicitly, otherwise Velocity merges in the bundled
    # default forced-hosts (lobby/factions/minigames) and fails validation.
    [forced-hosts]

    [ping-passthrough]
    version = false
    players = false
    description = true
    favicon = false
    modinfo = true

    [advanced]
    compression-threshold = 256
    login-ratelimit = 3000
    bungee-plugin-message-channel = true
    failover-on-unexpected-server-disconnect = true
    announce-proxy-commands = true
    accepts-transfers = false

    [query]
    enabled = false
    port = 25577
    show-plugins = false
  '';
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
      default = "4G";
      description = "JVM heap size for each backend server";
    };
    whitelist = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["eElyth" "BooKyyQLF" "Sami1018" "Mimitt"];
      description = "Minecraft usernames/UUIDs allowed to join the servers";
    };
    ops = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["eElyth" "Sami1018" "Mimitt"];
      description = "Minecraft usernames/UUIDs granted operator permissions";
    };
    icon = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = ../../../../kirk.png;
      description = "Path to an image used as the proxy server icon";
    };
    lobbyMap = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://example.com/my-lobby.zip";
      description = ''
        URL of a .zip/.tar.gz world archive to import as the lobby world.
        Only imported when the world does not already exist; delete
        ${storage}/lobby/data/world to force re-import.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."minecraft/forwarding-secret".mode = "0444";
    sops.templates."${name}/velocity-forwarding" = {
      content = ''
        FABRIC_PROXY_SECRET=${config.sops.placeholder."minecraft/forwarding-secret"}
        CFG_VELOCITY_SECRET=${config.sops.placeholder."minecraft/forwarding-secret"}
      '';
    };

    services.podman.containers =
      {
        ${proxyName} = {
          image = "docker.io/itzg/mc-proxy:java25";
          stack = name;
          ports = ["25565:25577"];
          environment =
            {
              TYPE = "VELOCITY";
              PUID = config.meadow.stacks.defaultUid;
              PGID = config.meadow.stacks.defaultGid;
              TZ = config.meadow.stacks.defaultTz;
              MEMORY = "1G";
              SYNC_SKIP_NEWER_IN_DESTINATION = "false";
              EXTRA_ARGS = "-Dvelocity.max-known-packs=101";
            }
            // lib.optionalAttrs (cfg.icon != null) {
              ICON = "/icon.png";
              OVERRIDE_ICON = "true";
            };
          volumes =
            [
              "${storage}/proxy:/server"
              "${velocityToml}:/config/velocity.toml:ro"
              "${forwardingSecretPath}:/config/forwarding.secret:ro"
            ]
            ++ lib.optionals (cfg.icon != null) [
              "${cfg.icon}:/icon.png:ro"
            ];
          homepage = {
            category = "Games";
            name = "MC Hardcore";
            settings = {
              description = "Soul Link hardcore Minecraft network";
              icon = "minecraft";
            };
          };
        };

        ${lobbyName} = {
          image = "docker.io/itzg/minecraft-server:latest";
          stack = name;
          environmentFile = [config.sops.templates."${name}/velocity-forwarding".path];
          environment =
            {
              EULA = "TRUE";
              TYPE = "PAPER";
              VERSION = "26.1.2";
              ONLINE_MODE = "FALSE";
              UID = config.meadow.facts.uid;
              GID = config.meadow.facts.gid;
              TZ = config.meadow.stacks.defaultTz;

              MODRINTH_PROJECTS = "crqzys-server-selector";

              MOTD = "§4BC §cHardcore §f- §aLobby";
              MAX_PLAYERS = toString cfg.maxPlayers;
              MEMORY = "1G";

              # Push our Paper/Velocity + selector config into /data, interpolating
              # ${CFG_VELOCITY_SECRET} from the sops-provided env file.
              COPY_CONFIG_SRC = "/lobby-config";
              COPY_CONFIG_DEST = "/data";
              SYNC_SKIP_NEWER_IN_DESTINATION = "false";
              REPLACE_ENV_DURING_SYNC = "true";
              REPLACE_ENV_VARIABLE_PREFIX = "CFG_";
            }
            // lib.optionalAttrs (cfg.lobbyMap != null) {
              WORLD = cfg.lobbyMap;
            };
          volumes = [
            "${storage}/lobby/data:/data"
            "${lobbyConfig}:/lobby-config:ro"
          ];
        };
      }
      // lib.genAttrs containerNames (cname: {
        image = "docker.io/itzg/minecraft-server:latest";
        stack = name;
        environmentFile = [config.sops.templates."${name}/velocity-forwarding".path];
        environment = {
          EULA = "TRUE";
          TYPE = "FABRIC";
          VERSION = "26.1";
          ONLINE_MODE = "FALSE";
          UID = config.meadow.facts.uid;
          GID = config.meadow.facts.gid;
          TZ = config.meadow.stacks.defaultTz;

          MODRINTH_PROJECTS = "soul-link-speedrun, fabric-api, fabricproxy-lite";
          FABRIC_PROXY_HACK_MESSAGE_CHAIN = "true";

          DIFFICULTY = "hard";
          MODE = "survival";
          MOTD = cfg.motd;
          MAX_PLAYERS = toString cfg.maxPlayers;
          MEMORY = cfg.memory;

          ENABLE_WHITELIST = "true";
          OVERRIDE_WHITELIST = "true";
          WHITELIST = builtins.concatStringsSep "," cfg.whitelist;
          OPS = builtins.concatStringsSep "," cfg.ops;
        };
        volumes = ["${storage}/${cname}/data:/data"];
      });
  };
}
