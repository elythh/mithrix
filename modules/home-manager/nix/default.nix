# This module is not enabled using an enable flag, because it contains essential settings, that should always be active.
{
  inputs,
  outputs,
  lib,
  config,
  osConfig ? {},
  pkgs,
  ...
}: let
  isStandalone = !config.submoduleSupport.enable;
in {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    {
      programs.nix-index-database.comma.enable = true;
      programs.nix-index.enable = true;
    }
  ];

  nix = {
    package = lib.mkIf isStandalone pkgs.nix;
    gc.automatic = true;
    # Run garbage collection every day at 12:30
    gc.frequency =
      if pkgs.stdenv.isLinux
      then "12:30"
      else "daily";
    settings = {
      extra-experimental-features = ["nix-command" "flakes" "pipe-operators"];
      warn-dirty = false;
    };
  };
  # Automatically start and drop systemd services as needed
  systemd.user.startServices = "sd-switch";

  # Disable nixpkgs overlays, if home-manager is running as submodule with useGlobalPkgs=true
  nixpkgs = lib.mkIf (isStandalone || !osConfig.home-manager.useGlobalPkgs) {
    # You can add overlays here

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home.packages = with pkgs; [nixd alejandra];
}
