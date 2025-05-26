{
  config,
  lib,
  ...
}: let
  name = "free-game";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/vogler/free-games-claimer:dev";
      port = 6080;
      traefik.name = name;
      volumes = [ "${storage}/fgc:/fgc/data"];
      environmentFile = [config.sops.secrets."free-game/env".path];
      environment = {
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
        TZ = config.tarow.stacks.defaultTz;
      };
      exec = "bash -c 'node epic-games; node prime-gaming; node gog; echo sleeping; sleep 1d'";

      homepage = {
        category = "Utilities";
        name = "Free Games";
        settings = {
          description = "Claim free games automatically";
          icon = "steam";
        };
      };
    };
  };
}
