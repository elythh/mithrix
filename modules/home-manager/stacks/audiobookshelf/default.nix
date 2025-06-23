{
  config,
  lib,
  ...
}: let
  name = "audiobookshelf";
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
  mediaStorage = config.meadow.stacks.mediaStorageBaseDir;
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/advplyr/audiobookshelf";
      volumes = [
        "${mediaStorage}/audiobooks:/audiobooks"
        "${storage}/podcasts:/podcasts"
        "${storage}/metadata:/metadata"
        "${storage}/config:/config"
      ];
      port = 80;
      traefik.name = name;
      homepage = {
        category = "Media";
        name = "Audiobookshelf";
        settings = {
          description = "Self-hosted audiobook and podcast server";
          icon = "audiobookshelf";
        };
      };
    };
  };
}
