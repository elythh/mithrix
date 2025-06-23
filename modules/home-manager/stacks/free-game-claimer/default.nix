{
  config,
  lib,
  ...
}: let
  name = "free-game";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/vogler/free-games-claimer:dev";
      port = 6080;
      traefik.name = name;
      volumes = [ "${storage}/fgc:/fgc/data"];
      environmentFile = [config.sops.secrets."free-game/env".path];
      environment = {
        PUID = config.meadow.stacks.defaultUid;
        PGID = config.meadow.stacks.defaultGid;
        TZ = config.meadow.stacks.defaultTz;
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
