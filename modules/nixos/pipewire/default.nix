{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.meadow.pipewire;
in {
  options.meadow.pipewire = {
    enable = lib.options.mkEnableOption "Pipewire";
  };

  config = lib.mkIf cfg.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
