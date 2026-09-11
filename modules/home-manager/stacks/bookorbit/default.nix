{
  config,
  lib,
  ...
}: let
  name = "bookorbit";
  dbName = "${name}-db";

  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/bookorbit/bookorbit:latest";
        dependsOn = [dbName];
        stack = name;

        environment = {
          NODE_ENV = "production";
          PORT = "3000";
          POSTGRES_HOST = dbName;
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";
          APP_URL = "https://${name}.${config.meadow.stacks.traefik.domain}";
          TZ = config.meadow.stacks.defaultTz;
          PUID = config.meadow.stacks.defaultUid;
          PGID = config.meadow.stacks.defaultGid;
          LIBRARY_BROWSE_ROOT = "/books";
        };
        environmentFile = [
          config.sops.secrets."bookorbit/env".path
          config.sops.secrets."bookorbit/db_env".path
        ];

        volumes = [
          "${storage}/data:/data"
          "${storage}/books:/books"
        ];

        addCapabilities = ["CAP_CHOWN" "CAP_DAC_OVERRIDE" "CAP_FOWNER" "CAP_SETGID" "CAP_SETUID"];
        dropCapabilities = ["ALL"];
        extraConfig.Container = {
          ReadOnly = true;
          Tmpfs = "/tmp";
          NoNewPrivileges = true;
          RunInit = true;
        };

        port = 3000;
        traefik = {
          name = name;
          subDomain = "bookorbit";
        };
        homepage = {
          category = "Media";
          name = "BookOrbit";
          settings = {
            description = "Self-hosted ebook, audiobook and comic library";
            icon = "bookshelf";
          };
        };
      };

      ${dbName} = {
        image = "docker.io/pgvector/pgvector:pg18";
        stack = name;

        environment = {
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";
          PGDATA = "/var/lib/postgresql/data/pgdata";
        };
        environmentFile = [config.sops.secrets."bookorbit/db_env".path];

        volumes = ["${storage}/postgres:/var/lib/postgresql/data"];
      };
    };
  };
}
