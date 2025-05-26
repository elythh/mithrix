{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.11";

  tarow = {
    core = {
      enable = true;
      configLocation = "~/nix-config#mithrix";
    };
    bootLoader.enable = true;
    docker.enable = false;
    shells.enable = true;
    wg-server.enable = false;
    sops = {
      enable = true;
      extraSopsFiles = [../../secrets/mithrix/secrets.yaml];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  time.timeZone = "Europe/Europe";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking = rec {
    firewall = {
      allowedUDPPorts = [53 80 443 51820];
      allowedTCPPorts = [21 53 80 443 8888] ++ (lib.range 40000 40009);
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

  services.prometheus.exporters.node = {
      enable = true;
      port = 9191;
      enabledCollectors = [ "systemd" ];
  };
}
