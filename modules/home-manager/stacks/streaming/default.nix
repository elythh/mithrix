{
  config,
  lib,
  ...
}: let
  stackName = "streaming";

  qbittorrentName = "qbittorrent";
  lidarrName = "lidarr";
  navidromeName = "navidrome";

  cfg = config.meadow.stacks.${stackName};
  storage = "${config.meadow.stacks.storageBaseDir}/${stackName}";
  mediaStorage = "${config.meadow.stacks.mediaStorageBaseDir}";
in {
  options.meadow.stacks.${stackName}.enable = lib.mkEnableOption stackName;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {

      ${qbittorrentName} = {
        image = "docker.io/linuxserver/qbittorrent:latest";
        volumes = [
          "${storage}/${qbittorrentName}:/config"
          "${mediaStorage}:/media"
        ];
        environmentFile = [config.sops.secrets."qbittorrent/env".path];
        environment = {
          PUID = config.meadow.stacks.defaultUid;
          PGID = config.meadow.stacks.defaultGid;
          UMASK = "022";
          WEBUI_PORT = 8080;
        };

        stack = stackName;
        port = 8080;
        traefik.name = qbittorrentName;
        homepage = {
          category = "Downloads";
          name = "qBittorrent";
          settings = {
            description = "BitTorrent client with Web UI";
            icon = "qbittorrent";
          };
        };
      };

      ${lidarrName} = {
        image = "lscr.io/linuxserver/lidarr:nightly";
        volumes = [
          "${storage}/${lidarrName}:/config"
          "${mediaStorage}:/data"
        ];
        environment = {
          PUID = config.meadow.stacks.defaultUid;
          PGID = config.meadow.stacks.defaultGid;
          TZ = config.meadow.stacks.defaultTz;
        };

        port = 8686;
        stack = stackName;
        traefik.name = lidarrName;
        homepage = {
          category = "Media";
          name = "Lidarr";
          settings = {
            description = "Music manager";
            icon = "Lidarr";
          };
        };
      };

      # soulseek = {
      #   image = "docker.io/slskd/slskd:latest";
      #   volumes = [
      #     "${storage}/slskd/data:/app"
      #     "${mediaStorage}:/data"
      #   ];
      #   environment = {
      #     SLSKD_REMOTE_CONFIGURATION = "true";
      #   };
      #
      #   port = 5030;
      #   stack = stackName;
      #   traefik.name = "soulseek";
      #   homepage = {
      #     category = "Media";
      #     name = "Soulseek";
      #     settings = {
      #       description = "Music downloader";
      #       icon = "Soulseek";
      #     };
      #   };
      # };

      soularr = {
        image = "docker.io/mrusse08/soularr:latest";
        volumes = [
          "${storage}/soularr:/data"
          "${mediaStorage}/downloads:/downloads"
        ];
        environment = {
          TZ = config.meadow.stacks.defaultTz;
        };
        stack = stackName;
      };

      navidrome = {
        image = "docker.io/deluan/navidrome:latest";
        volumes = [
          "${storage}/navidrome:/data"
          "${mediaStorage}/music:/music:ro"
        ];
        port = 4533;
        stack = stackName;
        traefik.name = navidromeName;
        environmentFile = [config.sops.secrets."navidrome/env".path];
        environment = {
          ND_LISTENBRAINZ_BASEURL="https://koito.elyth.xyz/apis/listenbrainz/1";
          ND_LISTENBRAINZ_ENABLED="true";
        };
        homepage = {
          category = "Media";
          name = "Navidrome";
          settings = {
            description = "Music livrary";
            icon = "navidrome";
          };
        };
      };

      explo = {
        image = "ghcr.io/lumepart/explo:latest";
        volumes = [
          "${mediaStorage}/music:/data"
          "${mediaStorage}/downloads:/slskd"
          "/home/gwen/.config/sops-nix/secrets/explo/env:/opt/explo/.env"
        ];
        stack = stackName;
        environment = {
          WEEKLY_EXPLORATION_SCHEDULE="*/3 * * * *"; 
          PATH="/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
        };
      };

      jellyfin = {
        image = "docker.io/jellyfin/jellyfin";
        volumes = [
          "${mediaStorage}/music:/media"
          "${storage}/jellyfin:/config"
        ];
        port = 8096;
        traefik.name = "jellyfin";
        stack = stackName;
      };

      # redis-allstarr = {
      #   image = "docker.io/redis:7-alpine";
      #   volumes = [
      #     "${storage}/allstarr/redis:/data"
      #   ];
      #   stack = stackName;
      # };
      #
      # allstarrr = {
      #   image = "ghcr.io/sopat712/allstarr:latest";
      #   port = 8080;
      #   traefik.name = "allstarr";
      #   volumes = [
      #     "${mediaStorage}/downloads:/app/downloads"
      #     "/home/gwen/.config/sops-nix/secrets/allstarr/env:/app/.env"
      #   ];
      #   environmentFile = [config.sops.secrets."allstarr/env".path];
      #   environment = {
      #     Redis__ConnectionString = "redis-allstarr:6379";
      #     Redis__Enabled = "true";
      #   };
      #   stack = stackName;
      #
      # };
    };
  };
}
