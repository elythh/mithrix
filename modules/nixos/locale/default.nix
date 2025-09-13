{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.meadow.locale;
in {
  options.meadow.locale = {
    enable = lib.options.mkEnableOption "Locale Settings";
  };

  config = lib.mkIf cfg.enable {
    time.hardwareClockInLocalTime = true;
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
