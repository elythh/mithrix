config: let
  domain = config.meadow.stacks.traefik.domain;
  ip = config.meadow.facts.ip4Address;
in ''
  interval: 300
  debounceTime: 10
  maxDebounceTime: 600

  webUI: true

  log:
    level: debug

  zones:
    - name: ${domain}
      provider: cloudflare
      apiToken: ${config.sops.placeholder."dockdns/apiToken"}
      zoneID: ${config.sops.placeholder."dockdns/zoneID"}

  dns:
    a: true
    aaaa: false
    defaultTTL: 300
    purgeUnknown: true

  domains:
    - name: "${domain}"

    - name: "*.${domain}"

    - name: "vpn.${domain}"

    - name: "lobby.${domain}"

    - name: "voice.${domain}"
''
