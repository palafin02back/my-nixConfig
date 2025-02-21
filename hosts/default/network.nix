{config, lib, pkgs, ...}: {
  networking = {
    useDHCP = false;
    networkmanager.enable = false;
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.31.101";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.31.250";
    nameservers = [
      "192.168.31.250"
      "223.6.6.6"
    ];
  };
}