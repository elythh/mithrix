{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.stacks;
in {
  imports =
    lib.tarow.readSubdirs ./.
    ++ [./extension.nix (lib.mkAliasOptionModule ["tarow" "containers"] ["services" "podman" "containers"])];

  options.tarow.stacks = {
    enable = lib.mkEnableOption "stacks";
    defaultUid = lib.mkOption {
      type = lib.types.int;
      default = 0;
    };
    defaultGid = lib.mkOption {
      type = lib.types.int;
      default = 0;
    };
    defaultTz = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
    };
    storageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/stacks";
    };
    externalStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/hdd1";
    };
    mediaStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.externalStorageBaseDir}/media";
    };
  };
  config = lib.mkIf cfg.enable {
    tarow.podman.enable = true;
  };
}
