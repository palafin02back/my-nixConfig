{config, pkgs, ...}: {
  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
}