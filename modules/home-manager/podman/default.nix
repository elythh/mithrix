{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.podman;
in {
  options.tarow.podman = with lib; {
    enable = mkEnableOption "Podman";

    enableSocket = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    socketLocation = lib.mkOption {
      type = lib.types.str;
      default = "/run/user/${toString config.tarow.facts.uid}/podman/podman.sock";
      readOnly = true;
    };
  };
  config = lib.mkIf cfg.enable {

    services.podman = {
      enable = true;
    };
    programs.fish.shellAbbrs = {
      psh = {
        expansion = "podman exec -it % /bin/sh";
        setCursor = true;
      };
      pl = "podman logs";
      plf = "podman logs -f";
    };
  };
}
