
{
  config,
  lib,
  ...
}: let
  name = "copyparty";
  storage = "${config.meadow.stacks.storageBaseDir}/${name}";
  cfg = config.meadow.stacks.${name};
in {
  options.meadow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/9001/copyparty-ac";
        volumes = [
          "${storage}/cfg:/cfg"
          "${storage}/movie:/movie"
        ];

        extraPodmanArgs = ["--memory=1g"];

        stack = name;
        port = 3923;
        traefik.name = name;
        homepage = {
          category = "Utilities";
          name = "copyparty";
          settings = {
            description = "Dead simple file server";
            icon = "files";
          };
        };
      };
    };
  };
}
