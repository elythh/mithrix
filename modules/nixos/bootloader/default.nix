{
  lib,
  config,
  ...
}: let
  cfg = config.meadow.bootLoader;
in {
  options.meadow.bootLoader = {
    enable = lib.options.mkEnableOption "Bootloader Config";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub = {
      enable = true;
      device = "nodev";
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
