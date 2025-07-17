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
      #
      # ftp = {
      #   image = "docker.io/garethflowers/ftp-server";
      #   volumes = [
      #     "${storage}/bookyytown:/home/gwen"
      #   ];
      #   environment = {
      #     PUBLIC_IP = "192.168.1.111";
      #     FTP_USER = "gwen";
      #     UID = "1000";
      #     GID = "1001";
      #   };
      #   ports = [
      #     "21:21"
      #     "40000-40009:40000-40009"
      #   ];
      #   environmentFile = [config.sops.secrets."ftp/env".path];
      # };

      mc-proxy = {
       image = "docker.io/itzg/mc-proxy";
        ports= [ "25565:25577" "25577:25577/udp" ];
        environment = {
          TYPE = "VELOCITY";
          PLUGINS = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.4.0/PAPER/ViaVersion-5.4.0.jar,https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/5.4.0/PAPER/ViaBackwards-5.4.0.jar";
          UID = config.meadow.stacks.defaultUid;
          GID = config.meadow.stacks.defaultGid;
          TZ = config.meadow.stacks.defaultTz;
          EXTRA_ARGS = "-Dvelocity.max-known-packs=101";
        };
        volumes = [
          "${storage}/proxy:/server"
        ];
        network = [ "mc-backend"];

      };
      # mc-home = {
      #  image = "docker.io/itzg/minecraft-server:java8";
      #   environment = {
      #     VERSION =  "1.8.8";
      #     EULA = "true";
      #     ONLINE_MODE= "FALSE";
      #     MEMORY = "16G";
      #     SPIGET_RESOURCES = "73113,9923";
      #     TYPE = "PAPER";
      #     UID = config.meadow.stacks.defaultUid;
      #     GID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #   volumes = [
      #     "${storage}/home:/data"
      #   ];
      #   network = [ "mc-backend"];
      # };
      bookyytown = {
       image = "docker.io/itzg/minecraft-server:latest";
        # ports= [ "25565:25565"];
        environment = {
          VERSION =  "1.21.1";
          NEOFORGE_VERSION = "21.1.152";
          EULA = "true";
          ONLINE_MODE= "FALSE";
          MEMORY = "20G";
          TYPE = "NEOFORGE";
          UID = config.meadow.stacks.defaultUid;
          GID = config.meadow.stacks.defaultGid;
          TZ = config.meadow.stacks.defaultTz;
        };
        volumes = [
          "${storage}/bookyytown/data:/data"
        ];
        network = [ "mc-backend"];
      };
      cinema = {
       image = "docker.io/itzg/minecraft-server:latest";
        # ports= [ "25565:25565"];
        environment = {
          VERSION =  "1.21.1";
          NEOFORGE_VERSION = "21.1.143";
          EULA = "true";
          ONLINE_MODE= "FALSE";
          MEMORY = "6G";
          TYPE = "NEOFORGE";
          UID = config.meadow.stacks.defaultUid;
          GID = config.meadow.stacks.defaultGid;
          TZ = config.meadow.stacks.defaultTz;
        };
        volumes = [
          "${storage}/cinema/data:/data"
        ];
        network = [ "mc-backend"];
      };
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
