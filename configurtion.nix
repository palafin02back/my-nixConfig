{ config, modulesPath, pkgs, lib, ... }:

{
  #############################################
  ###  Base System Configuration            ###
  #############################################
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
  system.stateVersion = "24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #############################################
  ###  Security Foundation                  ###
  #############################################
  security = {
    # SSH security baseline
    pam.services.sshd.allowNullPassword = false;
    
    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

  #############################################
  ###  Shell Environment                    ###
  #############################################
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "docker" "sudo" "command-not-found" ];
      theme = "robbyrussell";
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  #############################################
  ###  Font Configuration                   ###
  #############################################
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      wqy_microhei
      wqy_zenhei
    ];
  };

  #############################################
  ###  environment Configuration            ###
  #############################################
  environment.variables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  #############################################
  ###  Internationalization                 ###
  #############################################
  time.timeZone = "Asia/Shanghai";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        libpinyin
        rime
      ];
    };
  };

  #############################################t
  ###  Network Configuration                ###
  #############################################
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

  #############################################
  ###  User Management                      ###
  #############################################
  users = {
    mutableUsers = false;  # Declarative user management
    
    users = {
      root = {
        password = "passpapa";
      };

      knb = {
        isNormalUser = true;
        home = "/home/knb";
        description = "Primary User";
        extraGroups = [ "wheel" "networkmanager" "video" "render" "input" ];
        shell = pkgs.zsh;
        password = "knbbnk";
      };
    };
  };

  #############################################
  ###  SSH Configuration                    ###
  #############################################
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";          # Allow root password login
      PasswordAuthentication = true;    # Enable password authentication
      PermitEmptyPasswords = false;
      X11Forwarding = false;
    };
  };

  #############################################
  ###  Graphical Interface                  ###
  #############################################
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      desktopManager.gnome.enable = true;  # GNOME desktop
      displayManager.gdm.enable = true;    # GNOME display manager
    };

    # XRDP remote desktop configuration
    xrdp = {
      enable = true;
      defaultWindowManager = "gnome-session";
      openFirewall = true;
    };
  };

  #############################################
  ###  Hardware Acceleration                ###
  #############################################
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  #############################################
  ###  System Packages                      ###
  #############################################
  environment = {
    systemPackages = with pkgs; [
      # Core tools
      vim git wget sudo
      
      # Desktop applications
      firefox
      
      # Input method
      # ibus
      
      # System tools
      intel-gpu-tools glxinfo htop
      
      # GNOME packages
      orca
      evince
      geary
      gnome-disk-utility
      gnome-backgrounds
      gnome-color-manager
      gnome-shell-extensions
      gnome-user-docs
      gnome-tweaks
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
  };

  #############################################
  ###  Proxmox LXC Specific                 ###
  #############################################
  proxmoxLXC = {
    privileged = true;
    manageNetwork = true;
    manageHostName = false;
  };

  #############################################
  ###  System Optimizations                 ###
  #############################################
  systemd = {
    # Accelerate boot time
    services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    network.wait-online.enable = false;

    # Log configuration
    extraConfig = ''
      DefaultLimitNOFILE=102400
    '';
  };

  #############################################
  ###  Console Configuration                ###
  #############################################
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    earlySetup = true;
  };



}