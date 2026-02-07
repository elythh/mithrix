{
  config,
  lib,
  ...
}: let
  name = "lidify";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.meadow.stacks.mediaStorageBaseDir}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/chevron7locked/lidify:latest";
      volumes = [
        "${mediaStorage}/music:/music"
        "${storage}/data:/data"
      ];
      traefik = {
        name = name;
        subDomain = "music";
      };
      port = 3030;
      homepage = {
        category = "Media";
        name = "spotify";
        settings = {
          description = "Spotify Alternative";
          icon = "lidify";
        };
      };
      stack = name;
    };
  };
}
