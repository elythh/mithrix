{
  config,
  lib,
  ...
}: let
  name = "minecraft";
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
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

      mc-proxy = {
       image = "docker.io/itzg/mc-proxy";
        ports= [ "25565:25577"];
        environment = {
          TYPE = "VELOCITY";
          UID = config.meadow.stacks.defaultUid;
          GID = config.meadow.stacks.defaultGid;
          TZ = config.meadow.stacks.defaultTz;
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
      #     MEMORY = "12G";
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
      mc-rp = {
       image = "docker.io/itzg/minecraft-server:latest";
        environment = {
          VERSION =  "1.21.1";
          EULA = "true";
          ONLINE_MODE= "FALSE";
          MEMORY = "12G";
          TYPE = "NEOFORGE";
          UID = config.meadow.stacks.defaultUid;
          GID = config.meadow.stacks.defaultGid;
          TZ = config.meadow.stacks.defaultTz;
          CF_API_KEY = "$2a$10$BZZVwIQpNzAUAQOavsaLj.P8B8O3O/RW3uQ2WjkbINitf4UwmEb.q";
          CF_SERVER_MOD = "/modpacks/crazytown.zip";
        };
        volumes = [
          "${storage}/rp/data:/data"
          "${storage}/rp/modpacks:/modpacks:ro"
        ];
        network = [ "mc-backend"];
      };
    };
  };
}
