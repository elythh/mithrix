{
  config,
  lib,
  pkgs,
  ...
}: let
  name = "valheim";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";

  # Server_devcommands (JereKuusela) enables admin cheat/devcommands on a
  # dedicated server via BepInEx. Client must still have the mod (or -console).
  serverDevcommands = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/JereKuusela/Server_devcommands/1.115.0/";
    hash = "sha256-snUsGDQrycq/RzTjSAzSzEqp+qiVW6UD1PfO/Po+SzM=";
  };
  devcommandsPlugin = pkgs.runCommand "valheim-server-devcommands" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${serverDevcommands} ServerDevcommands.dll -d $out
  '';

  # SeneaL_UI (client-side UI overhaul) installed on the server as requested.
  senealUi = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/seneaL/SeneaL_UI/1.1.9/";
    hash = "sha256-yc3ZPkfZJdnB1TGt2GPNMreLPihfn3ceAF6acEAiF0c=";
  };
  senealUiPlugin = pkgs.runCommand "valheim-seneal-ui" {} ''
    mkdir -p $out
    cd $out
    ${pkgs.unzip}/bin/unzip -o ${senealUi} 'plugins/SeneaL-UI/*'
    mv plugins/SeneaL-UI SeneaL-UI
    rmdir plugins
  '';

  # ServerSideMapReborn: maintained fork that works with current Valheim.
  # Replaces the original ServerSideMap (which crashed the handshake).
  serverSideMapReborn = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/EVOLVEDS/ServerSideMapReborn/0.1.1/";
    hash = "sha256-HAieeT2a55TsqMdG5B06EiRTnyZEgcQjkdJIF0ebGFY=";
  };
  serverSideMapRebornPlugin = pkgs.runCommand "valheim-server-side-map-reborn" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${serverSideMapReborn} 'plugins/ServerSideMapReborn/*' -d $out
  '';

  # Enable shared markers (default is off) and map sharing on the server.
  serverSideMapRebornConfig = pkgs.writeText "local.valheim.serversidemapreborn.cfg" ''
    [General]

    ## Whether or not to allow map sharing
    EnableMapShare = true

    ## Whether or not to allow marker sharing
    EnableMarkerShare = true
  '';

  # MultiUserChest lets several players use the same chest at once. Needs
  # Jotunn, and must be installed (same version) on server and all clients.
  jotunn = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/ValheimModding/Jotunn/2.30.2/";
    hash = "sha256-iq6S2ivg62ggzUz1fi9sHWrQ1zjUkVlm58PXqU6amw8=";
  };
  jotunnPlugin = pkgs.runCommand "valheim-jotunn" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o -j ${jotunn} -d $out || true
  '';
  multiUserChest = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/MSchmoecker/MultiUserChest/0.6.2/";
    hash = "sha256-giIzmS7EfUOxNCZeV7QriWgkgvuIQAXDsjq6mMA1KUk=";
  };
  multiUserChestPlugin = pkgs.runCommand "valheim-multi-user-chest" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${multiUserChest} MultiUserChest.dll -d $out
  '';

  # DiscordConnector: posts server events to a Discord webhook (server-side).
  discordConnector = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/nwesterhausen/DiscordConnector/3.1.3/";
    hash = "sha256-QPl7W25dUj9vTxZZ77E4x7HdaTmSMFuFVWUaPyE2VOM=";
  };
  discordConnectorPlugin = pkgs.runCommand "valheim-discord-connector" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${discordConnector} DiscordConnector.dll -d $out
  '';
  discordConnectorToggles = pkgs.writeText "discordconnector-toggles.cfg" ''
    [Toggles.Messages]

    ## If enabled, this will send a message to Discord when the server saves the world.
    Server World Save Notifications = false
  '';

  # ReviveAlliesRevived: revive downed allies within a time window.
  reviveAllies = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/CyberFire/ReviveAlliesRevived/0.1.2/";
    hash = "sha256-y8M/cUPjbxrEASH4NzLa/rcBAotPbieBopt9CzGPluY=";
  };
  reviveAlliesPlugin = pkgs.runCommand "valheim-revive-allies" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${reviveAllies} ReviveAllies.dll -d $out
  '';

  # Seasons (+ deps: JsonDotNET, ConditionalConfigSync).
  seasons = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/shudnal/Seasons/1.10.5/";
    hash = "sha256-nUlP5IV3uO+j6AEHkXKIJcewXMCJt6kLLN7mLr/NsL4=";
  };
  seasonsPlugin = pkgs.runCommand "valheim-seasons" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${seasons} -d $out || true
    rm -f $out/*.md
  '';
  jsonDotnet = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/ValheimModding/JsonDotNET/13.0.4/";
    hash = "sha256-oiHHvnFjq5c5J0uWL70fY6veZbFBiDmmLwKsohCGgUc=";
  };
  jsonDotnetPlugin = pkgs.runCommand "valheim-jsondotnet" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${jsonDotnet} 'plugins/*' -d $out
  '';
  conditionalConfigSync = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/shudnal/ConditionalConfigSync/1.0.10/";
    hash = "sha256-z+pGGsNKlTuMJfxQFVFDFIzzE9iSiW0/TGtbITXu02k=";
  };
  conditionalConfigSyncPlugin = pkgs.runCommand "valheim-conditional-config-sync" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${conditionalConfigSync} '*.dll' -d $out
  '';

  # WellStocked: real shops / traders (needs Jotunn, already present).
  wellStocked = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/Einherjer/WellStocked/1.0.0/";
    hash = "sha256-HfY00GQmRekSePfdrES13edWy/FLWzkFbtgBLRdFWtI=";
  };
  wellStockedPlugin = pkgs.runCommand "valheim-well-stocked" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${wellStocked} 'plugins/*' -d $out
  '';

  # ValheimWebMap: server-side live web map (no client mods, no auth).
  valheimWebMap = pkgs.fetchurl {
    url = "https://thunderstore.io/package/download/koenhendriks/ValheimWebMap/1.0.2/";
    hash = "sha256-L7OM5O3Qj6drV2z/IFsTOE9qf3ohnMe2Dw0TaIj4h0M=";
  };
  valheimWebMapPlugin = pkgs.runCommand "valheim-web-map" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip -o ${valheimWebMap} 'plugins/ValheimWebMap/*' -d $out
  '';

  statusPort = 8098;

  # Tiny always-on page to show status and start/stop the server.
  valheimControl = pkgs.writeText "valheim-control.py" ''
    import http.server
    import json
    import os
    import subprocess
    import urllib.request
    from urllib.parse import parse_qs, urlparse

    UNIT = "podman-valheim.service"
    STATUS_URL = "http://127.0.0.1:${toString statusPort}/status.json"
    PORT = ${toString cfg.controlPort}
    CONFIG_DIR = os.environ.get("VALHEIM_CONFIG_DIR", "")
    BANNED_FILE = os.path.join(CONFIG_DIR, "bannedlist.txt") if CONFIG_DIR else ""
    BANNED_HEADER = "// List banned players ID  ONE per line"


    def run(*args):
        subprocess.run(["systemctl", "--user", *args], check=False)


    def is_active():
        r = subprocess.run(
            ["systemctl", "--user", "is-active", UNIT],
            capture_output=True, text=True,
        )
        return r.stdout.strip() == "active"


    def status():
        if not is_active():
            return None
        try:
            with urllib.request.urlopen(STATUS_URL, timeout=3) as f:
                return json.load(f)
        except Exception as e:  # noqa: BLE001
            return {"error": str(e)}


    def read_ids(path):
        try:
            with open(path) as f:
                return [ln.strip() for ln in f if ln.strip() and not ln.startswith("//")]
        except FileNotFoundError:
            return []


    def write_ids(path, ids):
        tmp = path + ".tmp"
        with open(tmp, "w") as f:
            f.write(BANNED_HEADER + "\n")
            for i in ids:
                f.write(i + "\n")
        os.replace(tmp, path)


    class Handler(http.server.BaseHTTPRequestHandler):
        def _send(self, code, obj):
            data = json.dumps(obj).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_GET(self):
            url = urlparse(self.path)
            if url.path == "/status.json":
                self._send(200, {"active": is_active(), "status": status()})
            elif url.path == "/moderation":
                self._send(200, {"banned": read_ids(BANNED_FILE) if BANNED_FILE else []})
            else:
                self._send(404, {"error": "not found"})

        def do_POST(self):
            url = urlparse(self.path)
            q = parse_qs(url.query)
            if url.path in ("/start", "/stop", "/restart"):
                run(url.path[1:], UNIT)
                self._send(200, {"ok": True})
            elif url.path in ("/ban", "/unban") and BANNED_FILE:
                pid = (q.get("id") or [""])[0].strip()
                if not pid:
                    self._send(400, {"ok": False, "error": "missing id"})
                    return
                ids = read_ids(BANNED_FILE)
                if url.path == "/ban":
                    if pid not in ids:
                        ids.append(pid)
                else:
                    ids = [i for i in ids if i != pid]
                try:
                    write_ids(BANNED_FILE, ids)
                    self._send(200, {"ok": True, "banned": ids})
                except Exception as e:  # noqa: BLE001
                    self._send(500, {"ok": False, "error": str(e)})
            else:
                self._send(404, {"error": "not found"})

        def log_message(self, *args):
            pass


    http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
  '';
in {
  options.meadow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Elyth Valheim";
      description = "Name shown in the Steam server browser";
    };
    worldName = lib.mkOption {
      type = lib.types.str;
      default = "Midgard";
      description = "Name of the world save directory";
    };
    public = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "List the server publicly in the Steam server browser";
    };
    admins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["76561198271668407"];
      description = "Admin SteamID64s (overrides /config/adminlist.txt)";
    };
    controlPort = lib.mkOption {
      type = lib.types.int;
      default = 8099;
      description = "Port for the status/start control page";
    };
    worldModifiers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {resources = "2";};
      example = {resources = "3"; raids = "more";};
      description = ''
        Valheim world modifiers passed as `-modifier <key> <value>`.
        Keys: combat, deaths, resources, raids, portals.
        resources accepts 1, 1.5, 2 or 3 (drops; x2 here).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.templates."${name}/env" = {
      content = "SERVER_PASS=${config.sops.placeholder."valheim/password"}";
    };

    sops.templates."${name}/discordconnector.cfg" = {
      content = ''
        [Main Settings]

        Webhook URL = ${config.sops.placeholder."valheim/discord-webhook"}
        Webhook Events = ALL
      '';
    };

    services.podman.containers.${name} = {
      image = "ghcr.io/lloesche/valheim-server:latest";
      stack = name;
      ports = [
        "2456-2458:2456-2458/udp"
        "127.0.0.1:${toString statusPort}:80/tcp"
      ];
      environmentFile = [config.sops.templates."${name}/env".path];
      environment = {
        TZ = config.meadow.stacks.defaultTz;
        SERVER_NAME = cfg.serverName;
        WORLD_NAME = cfg.worldName;
        SERVER_PUBLIC = lib.boolToString cfg.public;
        SERVER_ARGS = lib.optionalString (cfg.worldModifiers != {}) ("-modifier " + lib.concatStringsSep " " (lib.flatten (lib.mapAttrsToList (k: v: [k v]) cfg.worldModifiers)));
        ADMINLIST_IDS = builtins.concatStringsSep " " cfg.admins;
        BEPINEX = "true";
        STATUS_HTTP = "true";
        STATUS_HTTP_PORT = "80";
        STATUS_HTTP_CONF = "/config/httpd.conf";
        # BepInEx must be able to write mod configs; stage ours as a read-only
        # default and copy it into the (writable) config dir at startup.
        POST_BEPINEX_CONFIG_HOOK = "mkdir -p /opt/valheim/bepinex/BepInEx/config /opt/valheim/bepinex/BepInEx/config/games.nwest.valheim.discordconnector && cp -f /valheim-defaults/local.valheim.serversidemapreborn.cfg /opt/valheim/bepinex/BepInEx/config/local.valheim.serversidemapreborn.cfg && cp -f /valheim-defaults/discordconnector.cfg /opt/valheim/bepinex/BepInEx/config/games.nwest.valheim.discordconnector/discordconnector.cfg && cp -f /valheim-defaults/discordconnector-toggles.cfg /opt/valheim/bepinex/BepInEx/config/games.nwest.valheim.discordconnector/discordconnector-toggles.cfg && rm -f /opt/valheim/bepinex/BepInEx/plugins/ServerSideMap.dll";
        BACKUPS = "true";
        PUID = config.meadow.stacks.defaultUid;
        PGID = config.meadow.stacks.defaultGid;
      };
      volumes = [
        "${storage}/config:/config"
        "${storage}/data:/opt/valheim"
        "${devcommandsPlugin}/ServerDevcommands.dll:/config/bepinex/plugins/ServerDevcommands.dll:ro"
        "${senealUiPlugin}/SeneaL-UI:/config/bepinex/plugins/SeneaL-UI:ro"
        "${serverSideMapRebornPlugin}/plugins/ServerSideMapReborn:/config/bepinex/plugins/ServerSideMapReborn:ro"
        "${jotunnPlugin}:/config/bepinex/plugins/Jotunn:ro"
        "${multiUserChestPlugin}/MultiUserChest.dll:/config/bepinex/plugins/MultiUserChest.dll:ro"
        "${discordConnectorPlugin}/DiscordConnector.dll:/config/bepinex/plugins/DiscordConnector.dll:ro"
        "${reviveAlliesPlugin}/ReviveAllies.dll:/config/bepinex/plugins/ReviveAllies.dll:ro"
        "${jsonDotnetPlugin}/plugins:/config/bepinex/plugins/JsonDotNET:ro"
        "${conditionalConfigSyncPlugin}:/config/bepinex/plugins/ConditionalConfigSync:ro"
        "${wellStockedPlugin}/plugins:/config/bepinex/plugins/WellStocked:ro"
        "${seasonsPlugin}:/config/bepinex/plugins/Seasons:ro"
        "${valheimWebMapPlugin}/plugins/ValheimWebMap:/config/bepinex/plugins/ValheimWebMap:ro"
        "${serverSideMapRebornConfig}:/valheim-defaults/local.valheim.serversidemapreborn.cfg:ro"
        "${config.sops.templates."${name}/discordconnector.cfg".path}:/valheim-defaults/discordconnector.cfg:ro"
        "${discordConnectorToggles}:/valheim-defaults/discordconnector-toggles.cfg:ro"
      ];
      port = 3000;
      traefik = {
        name = name;
        subDomain = "map";
        middlewares = ["public"];
      };
      homepage = {
        category = "Games";
        name = "Valheim";
        settings = {
          description = "Dedicated Valheim server";
          icon = "steam";
        };
      };
    };

    systemd.user.services.valheim-control = {
      Unit = {
        Description = "Valheim status/start control page";
        After = ["network.target"];
      };
      Service = {
        ExecStart = "${pkgs.python3}/bin/python3 ${valheimControl}";
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/${toString config.meadow.facts.uid}"
          "VALHEIM_CONFIG_DIR=${storage}/config"
        ];
        Restart = "always";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
