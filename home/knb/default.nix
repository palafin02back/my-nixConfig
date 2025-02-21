{config, pkgs, lib, ...}: {
  imports = [
    ../common
    ./programs
    ./services
  ];

  home = {
    username = "knb";
    homeDirectory = lib.mkForce "/home/knb";  # 使用 mkForce 确保这个值优先级最高
    stateVersion = "24.11";
    
    packages = with pkgs; [
      git
      vim
      wget
      curl
      tmux
      htop
      ripgrep
      fd
      tree
    ];
  };

  programs.home-manager.enable = true;
}