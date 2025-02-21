{config, lib, pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Proxmox LXC specific settings
  proxmoxLXC = {
    privileged = true;
    manageNetwork = true;
    manageHostName = false;
  };
}