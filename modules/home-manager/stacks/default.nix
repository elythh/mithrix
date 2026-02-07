{
  lib,
  config,
  ...
}: let
  cfg = config.meadow.stacks;
in {
  imports =
    lib.meadow.readSubdirs ./.
    ++ [./extension.nix (lib.mkAliasOptionModule ["meadow" "containers"] ["services" "podman" "containers"])];

  options.meadow.stacks = {
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
      default = "/mnt";
    };
    mediaStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.externalStorageBaseDir}/storage/media";
    };
  };
  config = lib.mkIf cfg.enable {
    meadow.podman.enable = true;
  };
}
