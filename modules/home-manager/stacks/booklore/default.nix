{
  config,
  lib,
  ...
}: let
  name = "booklore";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {

  ${name} = {
      image = "ghcr.io/booklore-app/booklore:latest";
      environmentFile = [config.sops.secrets."booklore/env".path];
      stack = name;
      volumes = [
        "${storage}/booklore/books:/books:rw"
        "${storage}/booklore/data:/app/data"
        "${storage}/booklore/bookdrop:/bookdrop"
      ];

      dependsOn = [ "mariadb"];
      homepage = {
        category = "Media";
        name = "booklore";
        settings = {
          description = "Book Libary";
          icon = "booklore";
        };
      };
      traefik = {
        name = name;
        subDomain = "books";
      };
      port = 6060;
    };
    mariadb  = {
      image = "lscr.io/linuxserver/mariadb:11.4.5";
      environmentFile = [config.sops.secrets."mariadb/env".path];
      stack = name;
      volumes = [
        "${storage}/mariadb/config:/config"
      ];
    };
  };
};
}
