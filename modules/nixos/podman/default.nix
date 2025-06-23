{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.meadow.podman;
in {
  options.meadow.podman = {
    enable = lib.options.mkEnableOption "Podman";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
