{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.bootLoader;
in {
  options.tarow.bootLoader = {
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
