{
  lib,
  config,
  ...
}: let
  cfg = config.meadow.murmur;
in {
  options.meadow.murmur = {
    enable = lib.options.mkEnableOption "murmur Settings";
  };

  config = lib.mkIf cfg.enable {
    services.murmur = {
      enable = true;
      welcometext = "Bienvenue sur le serveur de BooKyQLF";
      extraConfig = ''
        ice="tcp -h 127.0.0.1 -p 6502"
      '';
      bandwidth = 120000;
      };
  };
}
