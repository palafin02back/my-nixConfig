{config, pkgs, ...}: {
    # System-wide packages
    environment.systemPackages = with pkgs; [
        # System essentials
        git
        vim
        wget
        curl
        sudo
        
        # System monitoring and maintenance
        htop
        intel-gpu-tools
        glxinfo
        libva-utils
        pciutils
        
        # Hardware support and drivers
        mesa
        libdrm
        
        # Desktop applications
        firefox
    ];
} 