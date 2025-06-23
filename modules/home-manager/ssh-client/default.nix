{
  lib,
  config,
  ...
}: let
  cfg = config.meadow.sshClient;
in {
  options.meadow.sshClient = {
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
