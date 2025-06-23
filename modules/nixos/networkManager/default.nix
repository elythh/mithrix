{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.meadow.networkManager;
in {
  options.meadow.networkManager = {
    enable = lib.options.mkEnableOption "NetworkManager";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
  };
}
