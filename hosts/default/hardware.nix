{config, lib, pkgs, ...}: {

  # X Server 配置
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
  };

  # LXC 容器配置
  proxmoxLXC = {
    privileged = true;
    manageNetwork = true;
    manageHostName = false;
  };
}
