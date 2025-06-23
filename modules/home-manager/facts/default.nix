{config, ...}: let
  cfg = config.meadow.facts;
in {
  config = {
    home.username = cfg.username;
    home.homeDirectory = "/home/${cfg.username}";
  };
}
