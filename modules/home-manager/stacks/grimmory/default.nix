{
  config,
  lib,
  ...
}: let
  name = "grimmory";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/grimmory-tools/grimmory:latest";
        environmentFile = [config.sops.secrets."booklore/env".path];
        stack = name;
        volumes = [
          "${storage}/books:/books:rw"
          "${storage}/data:/app/data"
          "${storage}/bookdrop:/bookdrop"
        ];

        dependsOn = ["mariadb"];
        homepage = {
          category = "Media";
          name = "Grimmory";
          settings = {
            description = "Self-hosted digital library";
            icon = "calibre-web";
          };
        };
        traefik = {
          name = name;
          subDomain = "books";
        };
        port = 6060;
      };
      mariadb = {
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
