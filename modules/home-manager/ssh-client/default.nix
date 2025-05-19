{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.sshClient;
in {
  options.tarow.sshClient = {
    enable = lib.options.mkEnableOption "SSH Client Config";
  };
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
      };
    };
  };
}
