{
  config,
  lib,
  ...
}: let
  name = "minecraft";
  storage = "${config.home.homeDirectory}/${name}";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.networks = {
      mc-backend = {
        driver  =  "bridge";
      };
    };
    services.podman.containers = {
      # mc-proxy = {
      #  image = "docker.io/itzg/mc-proxy";
      #   ports= [ "25565:25577" "25577:25577/udp" ];
      #   environment = {
      #     TYPE = "VELOCITY";
      #     UID = config.meadow.stacks.defaultUid;
      #     GID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #     EXTRA_ARGS = "-Dvelocity.max-known-packs=101";
      #   };
      #   volumes = [
      #     "${storage}/proxy:/server"
      #   ];
      #   network = [ "mc-backend"];
      #
      # };
      # bookyytown = {
      #  image = "docker.io/itzg/minecraft-server:latest";
      #   # ports= [ "25565:25565"];
      #   environment = {
      #     VERSION =  "1.21.1";
      #     NEOFORGE_VERSION = "21.1.152";
      #     EULA = "true";
      #     ONLINE_MODE= "FALSE";
      #     INIT_MEMORY = "6G";
      #     MAX_MEMORY = "24G";
      #     TYPE = "NEOFORGE";
      #     UID = config.meadow.stacks.defaultUid;
      #     GID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #     JVM_XX_OPTS = "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15";
      #   };
      #   volumes = [
      #     "${storage}/bookyytown/data:/data"
      #   ];
      #   network = [ "mc-backend"];
      # };
      # adventure = {
      #  image = "docker.io/itzg/minecraft-server:latest";
      #   environment = {
      #     VERSION =  "1.20.1";
      #     EULA = "true";
      #     CF_API_KEY = "$2a$10$BZZVwIQpNzAUAQOavsaLj.P8B8O3O/RW3uQ2WjkbINitf4UwmEb.q";
      #     ONLINE_MODE= "TRUE";
      #     INIT_MEMORY = "6G";
      #     MAX_MEMORY = "24G";
      #     TYPE = "FABRIC";
      #     UID = config.meadow.stacks.defaultUid;
      #     GID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #     JVM_XX_OPTS = "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15";
      #   };
      #   ports= [ "25565:25565" ];
      #   volumes = [
      #     "${storage}/adventureplus:/data"
      #   ];
      #   network = [ "mc-backend"];
      # };
      # cinema = {
      #  image = "docker.io/itzg/minecraft-server:latest";
      #   # ports= [ "25565:25565"];
      #   environment = {
      #     VERSION =  "1.21.1";
      #     NEOFORGE_VERSION = "21.1.152";
      #     EULA = "true";
      #     ONLINE_MODE= "FALSE";
      #     MEMORY = "6G";
      #     TYPE = "NEOFORGE";
      #     UID = config.meadow.stacks.defaultUid;
      #     GID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #   volumes = [
      #     "${storage}/cinema/data:/data"
      #   ];
      #   network = [ "mc-backend"];
      # };
      # bookyytown2 = {
      #  image = "docker.io/itzg/minecraft-server:latest";
      #   environment = {
      #     VERSION =  "1.20.1";
      #     NEOFORGE_VERSION = "47.1.106";
      #     EULA = "true";
      #     ONLINE_MODE= "FALSE";
      #     MEMORY = "6G";
      #     TYPE = "NEOFORGE";
      #     UID = config.meadow.stacks.defaultUid;
      #     GID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #   volumes = [
      #     "${storage}/bt2/data:/data"
      #   ];
      #   network = [ "mc-backend"];
      # };
    #   mc-sensible = {
    #    image = "docker.io/itzg/minecraft-server:latest";
    #     environment = {
    #       EULA = "true";
    #       ONLINE_MODE= "FALSE";
    #       MEMORY = "12G";
    #       TYPE = "FABRIC";
    #       VERSION = "1.21.1";
    #       UID = config.meadow.stacks.defaultUid;
    #       GID = config.meadow.stacks.defaultGid;
    #       TZ = config.meadow.stacks.defaultTz;
    #     };
    #     volumes = [
    #       "${storage}/sensible/data:/data"
    #     ];
    #     network = [ "mc-backend"];
    #   };
    };
  };
}
