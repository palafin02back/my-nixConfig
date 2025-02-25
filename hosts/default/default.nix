{config, lib, pkgs, modulesPath, ...}: {
  imports = [ 
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./hardware.nix
    ./network.nix
    ../../modules/desktop/gnome.nix
    ../../modules/system/fonts.nix
    ../../modules/system/i18n.nix
    ../../modules/system/security.nix
    ../../modules/system/packages.nix
  ];

  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic system configuration
  time.timeZone = "Asia/Shanghai";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    earlySetup = true;
  };

  # Enable zsh with global configuration
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "docker" "docker-compose" ];
    };
  };

  # Add user groups
  users.groups = {
    knb = {};
    render = {gid = 104; };
    video = { gid = 44; };
  };

  # Configure users
  users = {
    mutableUsers = false;  # Declarative user management
    
    users = {
      root = {
        password = "passpapa";
      };

      knb = {
        isNormalUser = true;
        group = "knb";  # Set primary group
        home = "/home/knb";
        description = "Primary User";
        extraGroups = [ "wheel" "networkmanager" "video" "render" "input" ];
        shell = pkgs.zsh;
        password = "knbbnk";
      };
    };
  };
}