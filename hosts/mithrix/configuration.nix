{
  pkgs,
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
    wg-server.enable = false;
    murmur.enable = true;
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

  time.timeZone = "Europe/Paris";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking = rec {
    firewall = {
      allowedUDPPorts = [53 80 443 25577 51820 64738];
      allowedTCPPorts = [21 22 53 80 443 6502 8080 8888 64738 25565] ++ (lib.range 40000 40009);
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

  systemd.timers."whitelist-off" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 19:30:00";
      # OnUnitActiveSec = "30s";
      # OnBootSec = "30s";
      Unit = "whitelist-bookyytown-off.service";
    };
  };
  systemd.services."whitelist-bookyytown-off" = {
    script = ''
      set -eu
      ${pkgs.podman}/bin/podman exec bookyytown rcon-cli -- whitelist off
    '';
    serviceConfig = {
      User = "gwen";
    };
  };

  systemd.timers."whitelist-on" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 01:00:00";
      # OnUnitActiveSec = "30s";
      # OnBootSec = "30s";
      Unit = "whitelist-bookyytown-on.service";
    };
  };
  systemd.services."whitelist-bookyytown-on" = {
    script = ''
      set -eu
      ${pkgs.podman}/bin/podman exec bookyytown rcon-cli -- whitelist on
      ${pkgs.podman}/bin/podman exec bookyytown rcon-cli -- say "Activation de la whitelist, à demain"
      sleep 10s
      ${pkgs.podman}/bin/podman exec bookyytown rcon-cli -- kick @a
    '';
    serviceConfig = {
      User = "gwen";
    };
  };
}
