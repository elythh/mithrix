{
  config,
  lib,
  ...
}: let
  name = "koito";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "docker.io/gabehf/koito:latest";
          dependsOn = [ "pg"];
        volumes = [
          "${storage}/koito/data:/etc/koito"
        ];
          environment = {
            KOITO_DATABASE_URL="postgres://postgres:secret_password@pg:5432/koitodb";
            KOITO_ALLOWED_HOSTS="koito.elyth.xyz,192.168.0.100:4110";
            KOITO_SUBSONIC_URL="https://navidrome.elyth.xyz";
            KOITO_SUBSONIC_PARAMS="u=elyth&t=4763f6aaeb37fbf45a208337220ec16b&s=081120";
            KOITO_ENABLE_LBZ_RELAY="true";
            KOITO_LBZ_RELAY_URL="https://api.listenbrainz.org/1";
            KOITO_LBZ_RELAY_TOKEN="7c52576c-74f4-4726-96b1-a9a169a2f35e";
          };
        traefik = {
          name = name;
          middlewares = ["public"];
        };
        port = 4110;
        stack = name;
        homepage = {
          category = "Media";
          name = "Koito";
          settings = {
            description = "ListenBrainz relay and music companion";
            icon = "navidrome";
          };
        };
      };
      pg = {
        image = "docker.io/postgres:16";
        stack = name;
        volumes = [
          "${storage}/koito/db:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_DB = "koitodb";
          POSTGRES_USER= "postgres";
          POSTGRES_PASSWORD= "secret_password";
        };
      };
    };
  };
}
