{pkgs ? import <nixpkgs> {}, ...}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes pipe-operators";
    packages = with pkgs; [
      nix
      home-manager
      git
      wget
      nh
      lazygit

      sops
      ssh-to-age
      age
    ];
  };
}
