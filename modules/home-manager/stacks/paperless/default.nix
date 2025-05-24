{
  config,
  lib,
  ...
}: let
  name = "paperless";
  dbName = "${name}-db";
  brokerName = "${name}-broker";

  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
        dependsOn = [dbName brokerName];
        volumes = [
          "${storage}/data:/usr/src/paperless/data"
          "${storage}/media:/usr/src/paperless/media"
          "${storage}/export:/usr/src/paperless/export"
          "${storage}/consume:/usr/src/paperless/consume"
        ];
        environment = {
          PAPERLESS_REDIS = "redis://${brokerName}:6379";
          PAPERLESS_DBHOST = dbName;
          PAPERLESS_DBNAME = config.services.podman.containers.${dbName}.environment.POSTGRES_DB;
          PAPERLESS_DBUSER = config.services.podman.containers.${dbName}.environment.POSTGRES_USER;
          USERMAP_UID = config.tarow.stacks.defaultUid;
          USERMAP_GID = config.tarow.stacks.defaultGid;
          PAPERLESS_OCR_LANGUAGES = "eng fra";
          PAPERLESS_TIME_ZONE = config.tarow.stacks.defaultTz;
          PAPERLESS_OCR_LANGUAGE = "deu";
          PAPERLESS_FILENAME_FORMAT = "{{created_year}}/{{correspondent}}/{{title}}";
          PAPERLESS_URL = "https://${name}.${config.tarow.stacks.traefik.domain}";
        };
        environmentFile = [config.sops.secrets."paperless/env".path];

        port = 8000;
        traefik.name = name;

        stack = name;
      };

      ${brokerName} = {
        image = "docker.io/redis:6.0";

        stack = name;
      };

      ${dbName} = {
        image = "docker.io/postgres:16";
        volumes = ["${storage}/db:/var/lib/postgresql/data"];
        environment = {
          POSTGRES_DB = "paperless";
          POSTGRES_USER = "paperless";
        };
      environmentFile = [config.sops.secrets."paperless/db_env".path];

        stack = name;
      };
    };
  };
}
