{config, ...}:{
    services.podman.containers.calibre = {
      image = "lscr.io/linuxserver/calibre-web";
      environment = {
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
        TZ = config.tarow.stacks.defaultTz;
      };
      ports = [ "40001:8083" ] ;
    };
}
