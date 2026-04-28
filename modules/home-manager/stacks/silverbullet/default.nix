{
  config,
  lib,
  ...
}: let
  name = "silverbullet";
  cfg = config.meadow.stacks.${name};
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/silverbulletmd/silverbullet:v2";
      volumes = ["${storage}/space:/space"];
      port = 3000;
      traefik.name = "notes";
      homepage = {
        category = "Utilities";
        name = "Silverbullet";
        settings = {
          description = "Markdown note editor";
          icon = "silverbullet";
        };
      };
    };
  };
}
