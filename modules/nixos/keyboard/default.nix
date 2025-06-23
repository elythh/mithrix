{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.meadow.keyboard;
in {
  options.meadow.keyboard = {
    enable = lib.options.mkEnableOption "Keyboard Settings";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.xkb.layout = "eu";
  };
}
