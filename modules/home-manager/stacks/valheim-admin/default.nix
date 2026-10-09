{
  config,
  lib,
  ...
}: let
  name = "valheim-admin";
  cfg = config.meadow.stacks.${name};
  valheimStorage = "${config.meadow.stacks.storageBaseDir}/valheim";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    sops.templates."${name}/env" = {
      content = ''
        OIDC_CLIENT_ID=${config.sops.placeholder."valheim-admin/oidc-client-id"}
        OIDC_CLIENT_SECRET=${config.sops.placeholder."valheim-admin/oidc-client-secret"}
        SESSION_SECRET=${config.sops.placeholder."valheim-admin/session-secret"}
      '';
    };

    services.podman.containers.${name} = {
      image = "localhost/valheim-admin:latest";
      autoUpdate = null;
      environmentFile = [config.sops.templates."${name}/env".path];
      environment = {
        PORT = "3000";
        CONTROL_URL = "http://host.containers.internal:8099";
        MAP_URL = "https://map.elyth.xyz";
        LOG_FILE = "/valheim/bepinex/BepInEx/LogOutput.log";
        OIDC_ISSUER = "https://auth.elyth.xyz";
        OIDC_REDIRECT_URI = "https://valheim.elyth.xyz/auth/callback";
      };
      volumes = [
        "${valheimStorage}/data:/valheim:ro"
      ];
      port = 3000;
      traefik = {
        name = name;
        subDomain = "valheim";
        middlewares = [];
      };
      homepage = {
        category = "Games";
        name = "Valheim Admin";
        settings = {
          description = "Valheim server admin";
          icon = "steam";
        };
      };
    };
  };
}
