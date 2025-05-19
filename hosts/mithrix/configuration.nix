{
  config,
  lib,
  pkgs,
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
    docker.enable = true;
    shells.enable = true;
    sops = {
      enable = true;
      extraSopsFiles = [../../secrets/mithrix/secrets.yaml];
    };

    wg-server.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  time.timeZone = "Europe/Berlin";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking.firewall.allowedUDPPorts = [53 80 443 51820];
  networking.firewall.allowedTCPPorts = [21 53 80 443 8888] ++ (lib.range 40000 40009);
  networking.hostName = "mithrix";

  services.prometheus.exporters.node = {
      enable = true;
      port = 9191;
      enabledCollectors = [ "systemd" ];
  };
}
