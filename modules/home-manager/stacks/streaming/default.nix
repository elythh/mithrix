{
  config,
  lib,
  ...
}: let
  stackName = "streaming";

  gluetunName = "gluetun";
  qbittorrentName = "qbittorrent";
  jellyfinName = "jellyfin";
  sonarrName = "sonarr";
  radarrName = "radarr";
  bazarrName = "bazarr";
  lidarrName = "lidarr";
  prowlarrName = "prowlarr";
  navidromName = "navidrome";

  cfg = config.meadow.stacks.${stackName};
  storage = "${config.meadow.stacks.storageBaseDir}/${stackName}";
  mediaStorage = "${config.meadow.stacks.mediaStorageBaseDir}";
in {
  options.meadow.stacks.${stackName}.enable = lib.mkEnableOption stackName;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      # ${gluetunName} = {
      #   image = "docker.io/qmcgaw/gluetun:latest";
      #   addCapabilities = ["NET_ADMIN"];
      #   devices = ["/dev/net/tun:/dev/net/tun"];
      #   # volumes = [
      #   #   "${config.sops.secrets."gluetun/config".path}:/gluetun/auth/config.toml"
      #   # ];
      #   environmentFile = [config.sops.secrets."gluetun/env".path];
      #   environment = {
      #     WIREGUARD_MTU = 1320;
      #     HTTP_CONTROL_SERVER_LOG = "off";
      #     VPN_SERVICE_PROVIDER = "airvpn";
      #     VPN_TYPE = "wireguard";
      #     TZ = config.meadow.stacks.defaultTz;
      #     UPDATER_PERIOD = "12h";
      #     HTTPPROXY = "on";
      #     HEALTH_VPN_DURATION_INITIAL = "60s";
      #   };
      #   network = [config.meadow.stacks.traefik.network];
      #
      #   stack = stackName;
      #   port = 8888;
      #   homepage = {
      #     category = "Networking";
      #     name = "Gluetun";
      #     settings = {
      #       description = "VPN client with firewall and proxy";
      #       icon = "gluetun";
      #     };
      #   };
      # };
      #
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

      # ${jellyfinName} = {
      #   image = "lscr.io/linuxserver/jellyfin:latest";
      #   volumes = [
      #     "${storage}/${jellyfinName}:/config"
      #     "${mediaStorage}:/media"
      #   ];
      #   devices = ["/dev/dri:/dev/dri"];
      #   environment = {
      #     PUID = config.meadow.stacks.defaultUid;
      #     PGID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #     JELLYFIN_PublishedServerUrl = config.services.podman.containers.${jellyfinName}.traefik.serviceDomain;
      #   };
      #
      #   port = 8096;
      #   stack = stackName;
      #   traefik.name = jellyfinName;
      #   homepage = {
      #     category = "Media";
      #     name = "Jellyfin";
      #     settings = {
      #       description = "Self-hosted media server";
      #       icon = "jellyfin";
      #     };
      #   };
      # };
      #
      # ${sonarrName} = {
      #   image = "lscr.io/linuxserver/sonarr:latest";
      #   volumes = [
      #     "${storage}/${sonarrName}:/config"
      #     "${mediaStorage}:/media"
      #   ];
      #   environment = {
      #     PUID = config.meadow.stacks.defaultUid;
      #     PGID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #
      #   port = 8989;
      #   stack = stackName;
      #   traefik.name = sonarrName;
      #   homepage = {
      #     category = "Media";
      #     name = "Sonarr";
      #     settings = {
      #       description = "Series Management";
      #       icon = "sonarr";
      #     };
      #   };
      # };
      #
      # ${radarrName} = {
      #   image = "lscr.io/linuxserver/radarr:latest";
      #   volumes = [
      #     "${storage}/${radarrName}:/config"
      #     "${mediaStorage}:/media"
      #   ];
      #   environment = {
      #     PUID = config.meadow.stacks.defaultUid;
      #     PGID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #
      #   port = 7878;
      #   stack = stackName;
      #   traefik.name = radarrName;
      #   homepage = {
      #     category = "Media";
      #     name = "Radarr";
      #     settings = {
      #       description = "Movie Management";
      #       icon = "radarr";
      #     };
      #   };
      # };

      # ${bazarrName} = {
      #   image = "lscr.io/linuxserver/bazarr:latest";
      #   volumes = [
      #     "${storage}/${bazarrName}:/config"
      #     "${mediaStorage}:/media"
      #   ];
      #   environment = {
      #     PUID = config.meadow.stacks.defaultUid;
      #     PGID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #
      #   port = 6767;
      #   stack = stackName;
      #   traefik.name = bazarrName;
      #   homepage = {
      #     category = "Media";
      #     name = "Bazarr";
      #     settings = {
      #       description = "Subtitle Management";
      #       icon = "bazarr";
      #     };
      #   };
      # };
      #
      # ${prowlarrName} = {
      #   image = "lscr.io/linuxserver/prowlarr:latest";
      #   volumes = [
      #     "${storage}/${prowlarrName}:/config"
      #   ];
      #   environment = {
      #     PUID = config.meadow.stacks.defaultUid;
      #     PGID = config.meadow.stacks.defaultGid;
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #
      #   port = 9696;
      #   stack = stackName;
      #   traefik.name = prowlarrName;
      #   homepage = {
      #     category = "Media";
      #     name = "Prowlarr";
      #     settings = {
      #       description = "Indexer Management";
      #       icon = "prowlarr";
      #     };
      #   };
      # };

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

      soulseek = {
        image = "docker.io/slskd/slskd:latest";
        volumes = [
          "${storage}/data:/app"
          "${mediaStorage}:/data"
        ];
        environment = {
          SLSKD_REMOTE_CONFIGURATION = "true";
        };

        port = 5030;
        stack = stackName;
        traefik.name = "soulseek";
        homepage = {
          category = "Media";
          name = "Soulseek";
          settings = {
            description = "Music downloader";
            icon = "Soulseek";
          };
        };
      };

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
        traefik.name = "navidrome";
        environmentFile = [config.sops.secrets."navidrome/env".path];
        homepage = {
          category = "Media";
          name = "Navidrome";
          settings = {
            description = "Music livrary";
            icon = "navidrome";
          };
        };
      };

      # flaresolverr = {
      #   image = "ghcr.io/flaresolverr/flaresolverr:latest";
      #   volumes = [
      #     "${storage}/${prowlarrName}:/config"
      #   ];
      #   environment = {
      #     LOG_LEVEL = "info";
      #     LOG_HTML = false;
      #     CAPTCHA_SOLVER = "none";
      #     TZ = config.meadow.stacks.defaultTz;
      #   };
      #
      #   stack = stackName;
      #   homepage = {
      #     category = "Media";
      #     name = "Flaresolverr";
      #     settings = {
      #       icon = "flaresolverr";
      #       description = "Cloudflare Protection Bypass";
      #     };
      #   };
      # };
    };
  };
}
