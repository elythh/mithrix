{
  lib,
  config,
  ...
}: {
  imports = [
    #{meadow.stacks.enable = lib.mkForce false;}
    {
      meadow = lib.meadow.enableModules [
        "core"
        "git"
        "shells"
	      "sops"
      ];
    }
  ];

  home.stateVersion = "24.11";
  # sops.secrets."ssh_authorized_keys".path = "${config.home.homeDirectory}/.ssh/authorized_keys";


  meadow = {
    facts.ip4Address = "192.168.1.111";
    core.configLocation = "~/nix-config#homeserver";

    podman.enable = true;
    stacks = {
      enable = true;
      paperless.enable = true;
      immich.enable = true;
      homepage.enable = true;
      beszel.enable = true;
      wg-easy.enable = true;
      dozzle.enable = true;
      audiobookshelf.enable = true;
      streaming.enable = true;
      aiostreams.enable = true;
      free-game.enable = true;
      monitoring.enable = true;
      minecraft.enable = true;
      copyparty.enable = true;
      traefik = {
          enable = true;
          domain = "elyth.xyz";
        };
    };
  };
}
