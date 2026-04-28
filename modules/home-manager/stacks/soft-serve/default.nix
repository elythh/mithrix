{
  config,
  lib,
  ...
}: let
  optionName = "softserve";
  containerName = "soft-serve";
  cfg = config.meadow.stacks.${optionName};
  storage = "${config.meadow.stacks.storageBaseDir}/${containerName}";
in {
  options.meadow.stacks.${optionName} = {
    enable = lib.mkEnableOption containerName;
    displayName = lib.mkOption {
      type = lib.types.str;
      default = "Soft Serve";
      description = "Display name shown in the Soft Serve UI header.";
    };
    sshPublicUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public SSH URL shown in clone/push commands (e.g. ssh://git.example.com).";
    };
    repos = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Repositories to mirror into Soft Serve (name = clone URL).";
    };
    initialAdminPublicKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SSH public key used for Soft Serve first-run admin bootstrap.";
    };
    initialAdminPublicKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to SSH public key file for Soft Serve first-run admin bootstrap.";
    };
    syncInterval = lib.mkOption {
      type = lib.types.str;
      default = "30m";
      description = "How often to sync public GitHub repositories into Soft Serve.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.containers.${containerName} = {
      image = "docker.io/charmcli/soft-serve:latest";
      volumes = [
        "${storage}/data:/data"
      ] ++ lib.optional (cfg.initialAdminPublicKeyFile != null) "${cfg.initialAdminPublicKeyFile}:/tmp/initial_admin_key.pub:ro";
      ports = ["22:23231"];
      environment =
        {
          SOFT_SERVE_DATA_PATH = "/data";
          SOFT_SERVE_NAME = cfg.displayName;
        }
        // lib.optionalAttrs (cfg.sshPublicUrl != null) {
          SOFT_SERVE_SSH_PUBLIC_URL = cfg.sshPublicUrl;
        }
        // lib.optionalAttrs (cfg.initialAdminPublicKey != null) {
          SOFT_SERVE_INITIAL_ADMIN_KEYS = cfg.initialAdminPublicKey;
        }
        // lib.optionalAttrs (cfg.initialAdminPublicKeyFile != null) {
          SOFT_SERVE_INITIAL_ADMIN_KEYS = "/tmp/initial_admin_key.pub";
        };
      stack = containerName;
      homepage = {
        category = "Development";
        name = "Soft Serve";
        settings = {
          description = "Self-hosted Git over SSH";
          icon = "github";
        };
      };
    };
  };
}
