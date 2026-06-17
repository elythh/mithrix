{
  config,
  lib,
  ...
}: let
  name = "koito";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name} = {
    enable = lib.mkEnableOption name;

    multiScrobbler = {
      enable = lib.mkEnableOption "foxxmd/multi-scrobbler bridge from Last.fm to Koito";
      envSecret = lib.mkOption {
        type = lib.types.str;
        default = "multi-scrobbler/env";
        description = "SOPS secret key containing Multi-Scrobbler environment variables.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (!cfg.multiScrobbler.enable) || builtins.hasAttr cfg.multiScrobbler.envSecret config.sops.secrets;
        message = "meadow.stacks.koito.multiScrobbler.envSecret must exist in sops.secrets.";
      }
    ];

    services.podman.containers = {
      ${name} = {
        image = "docker.io/gabehf/koito:latest";
          dependsOn = [ "pg"];
        volumes = [
          "${storage}/koito/data:/etc/koito"
        ];
        environmentFile = [config.sops.secrets."koito/env".path];
        environment =
          {
            KOITO_ENABLE_LBZ_RELAY = "true";
            KOITO_LBZ_RELAY_URL = "https://api.listenbrainz.org/1";
            KOITO_LBZ_RELAY_TOKEN = "7c52576c-74f4-4726-96b1-a9a169a2f35e";

            # Ensure the canonical endpoint is used even if a stale value exists in env file.
            KOITO_MUSICBRAINZ_URL = "https://musicbrainz.org";
            KOITO_FETCH_IMAGES_DURING_IMPORT = "true";

            KOITO_LOG_LEVEL="debug";
          }
          // lib.optionalAttrs (builtins.hasAttr "lastfm/api_key" config.sops.secrets) {
            KOITO_LASTFM_API_KEY_FILE = config.sops.secrets."lastfm/api_key".path;
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
      multi-scrobbler = lib.mkIf cfg.multiScrobbler.enable {
        image = "docker.io/foxxmd/multi-scrobbler:latest";
        stack = name;
        dependsOn = [name];
        volumes = [
          "${storage}/multi-scrobbler/config:/config"
        ];
        port = 9078;
        traefik.name = "scrobbler";
        environmentFile = [config.sops.secrets.${cfg.multiScrobbler.envSecret}.path];
        environment = {
          TZ = config.meadow.stacks.defaultTz;
          BASE_URL = "https://scrobbler.${config.meadow.stacks.traefik.domain}";
          SOURCE_LASTFM_REDIRECT_URI = "https://scrobbler.${config.meadow.stacks.traefik.domain}/lastfm/callback";
          KOITO_URL = "https://koito.${config.meadow.stacks.traefik.domain}";
        };
        homepage = {
          category = "Media";
          name = "Multi-Scrobbler";
          settings = {
            description = "Bridge scrobbles from Last.fm to Koito";
            icon = "lastfm";
          };
        };
      };
    };
  };
}
