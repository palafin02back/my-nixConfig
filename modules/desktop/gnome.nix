{config, pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };

    xrdp = {
      enable = true;
      defaultWindowManager = "gnome-session";
      openFirewall = true;
    };
  };

  # GNOME packages
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnome-backgrounds
    gnome-color-manager
    gnome-shell-extensions
    gnome-user-docs
    gsettings-desktop-schemas
    
    # GNOME applications
    baobab
    epiphany
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-system-monitor
    gnome-weather
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
  ];
}