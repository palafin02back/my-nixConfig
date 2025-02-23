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
      # Development tools
      ripgrep  # Better grep
      fd       # Better find
      tree     # Directory structure viewer
      
      # Version control
      git-lfs
      git-crypt
      
      # Text processing
      jq       # JSON processor
      yq       # YAML processor
      
      # Network tools
      httpie   # HTTP client
      
      # System monitoring (user level)
      bottom   # System monitor
      duf      # Disk usage
    ];
  };

  programs.home-manager.enable = true;
}