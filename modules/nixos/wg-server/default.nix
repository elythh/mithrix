{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  cfg = config.tarow.wg-server;
in {
  options.tarow.wg-server = with lib; {
    enable = mkEnableOption "Wireguard Server";
    port = mkOption {
      type = types.port;
      default = 51820;
    };
    internalInterface = mkOption {
      type = types.str;
      default = "wg0";
    };
    externalInterface = mkOption {
      type = types.str;
      default = "enp1s0";
    };
    ip = mkOption {
      type = types.str;
      default = "10.2.2.1/24";
    };
    privateKeyFile = mkOption {
      type = types.str;
      default = config.sops.secrets."wireguard/pk".path;
    };
    peers =
      (options.networking.wireguard.interfaces.type.getSubOptions []).peers
      // {default = lib.removeAttrs (import ./peers.nix config) ["mithrix"] |> lib.attrValues;};
    endpoint = mkOption {
      type = types.str;
      default = (import ./peers.nix config).mithrix.endpoint;
    };
  };
  config = lib.mkIf cfg.enable {
    networking.nat.enable = true;
    networking.nat.externalInterface = cfg.externalInterface;
    networking.nat.internalInterfaces = [cfg.internalInterface];
    networking.firewall = {
      allowedUDPPorts = [cfg.port];
    };

    networking.wireguard.interfaces.${cfg.internalInterface} = {
      ips = [cfg.ip];
      listenPort = cfg.port;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.ip} -o ${cfg.externalInterface} -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.ip} -o ${cfg.externalInterface} -j MASQUERADE
      '';

      privateKeyFile = cfg.privateKeyFile;
      inherit (cfg) peers;
    };

    environment.systemPackages = [
      (pkgs.callPackage
        ./genClientConfig.nix
        {
          serverPubKey = (import ./peers.nix config).mithrix.publicKey;
          serverEndpoint = "${cfg.endpoint}:${toString cfg.port}";
        })
    ];
  };
}
