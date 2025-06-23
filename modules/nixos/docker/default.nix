{
  lib,
  config,
  ...
}: let
  cfg = config.meadow.docker;
in {
  options.meadow.docker = {
    enable = lib.options.mkEnableOption "Docker";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
