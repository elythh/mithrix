{
  config,
  lib,
  ...
}: let
  name = "mumble";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/mumblevoip/mumble-server:latest";
      ports= [ "64738:64738"];
      environment = {
        PUID = config.meadow.stacks.defaultUid;
        PGID = config.meadow.stacks.defaultGid;
        TZ = config.meadow.stacks.defaultTz;
      };
    };
  };
}
