{
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.11";

  meadow = {
    core = {
      enable = true;
      configLocation = "~/nix-config#mithrix";
    };
    bootLoader.enable = true;
    docker.enable = false;
    shells.enable = true;
    murmur.enable = true;
    sops = {
      enable = true;
      extraSopsFiles = [../../secrets/mithrix/secrets.yaml];
    };
  };

  time.timeZone = "Europe/Paris";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking = rec {
    firewall = {
      allowedUDPPorts = [53 80 443 25577 51820 64738];
      allowedTCPPorts = [21 22 53 80 443 3923 6502 8080 8888 64738 25565] ++ (lib.range 40000 40009);
    };
    hostName = "mithrix";
    defaultGateway = "192.168.1.254";
    nameservers = [defaultGateway];
    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = "192.168.1.111";
          prefixLength = 24;
        }
      ];
    };
  };

    fileSystems."/mnt/storage" = {
    device = "u542537@u542537.your-storagebox.de:/home";
    fsType = "fuse.sshfs";
    options = [
      "port=23"
      "identityfile=/home/gwen/.ssh/id_default"
      "idmap=user"
      "x-systemd.automount" # mount the filesystem automatically on first access
      "allow_other" # don't restrict access to only the user which `mount`s it (because that's probably systemd who mounts it, not you)
      "user" # allow manual `mount`ing, as ordinary user.
      "_netdev"
      "StrictHostKeyChecking=accept-new"
    ];
  };
  boot.supportedFilesystems."fuse.sshfs" = true;

  services.comin = {
    enable = true;
    remotes = [{
      name = "origin";
      url = "https://github.com/elythh/mithrix";
      branches.main.name = "main";
    }];
  };
  services.prometheus.exporters.node = {
      enable = true;
      port = 9191;
      enabledCollectors = [ "systemd" ];
  };
}
