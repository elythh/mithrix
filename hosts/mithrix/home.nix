{
  lib,
  config,
  ...
}: {
  imports = [
    #{tarow.stacks.enable = lib.mkForce false;}
    {
      tarow = lib.tarow.enableModules [
        "core"
        "git"
        "shells"
	      "sops"
      ];
    }
  ];

  home.stateVersion = "24.11";
  sops.secrets."ssh_authorized_keys".path = "${config.home.homeDirectory}/.ssh/authorized_keys";

  tarow = {
    facts.ip4Address = "192.168.1.111";
    core.configLocation = "~/nix-config#homeserver";

    podman.enable = true;
    stacks = {
      enable = true;
      calibre.enable = true;
      paperless.enable = true;
      immich.enable = true;
      traefik = {
          enable = true;
          domain = "elyth.xyz";
        };
    };
  };
}
