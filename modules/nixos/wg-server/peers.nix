config: {
  mithrix = {
    name = "mithrix";
    endpoint = "vpn.elyth.xyz";
    publicKey = "RdH9AITAlDJVIhcJV/0kkvk3mJ60LcLnPfD8uHKpMRY=";
  };
  phone = {
    name = "phone";
    publicKey = "RdH9AITAlDJVIhcJV/0kkvk3mJ60LcLnPfD8uHKpMRY=";
    presharedKeyFile = config.sops.secrets."wireguard/psk_phone".path;
    allowedIPs = ["10.2.2.100"];
  };
}
