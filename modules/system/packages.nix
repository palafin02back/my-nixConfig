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
        
        # Development tools
        gcc
        gnumake
        
        # # Hardware support
        # intel-media-driver
        # intel-compute-runtime
        # vaapiIntel
        # vaapiVdpau
        # libvdpau-va-gl
        
        # Desktop applications
        firefox
        

    ];
} 