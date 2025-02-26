{ config, modulesPath, pkgs, lib, ... }:

    {
    imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
    
    # 内核和启动配置
    boot = {
        initrd.kernelModules = [ "i915" ];
        kernelParams = [ "i915.force_probe=46d1" ];
        kernelPackages = pkgs.linuxPackages_latest;
    };

    # 基本系统设置
    system.stateVersion = "24.11";
    nix.settings = {
        experimental-features = [ "nix-command" ];
        sandbox = false;
    };
    time.timeZone = "Asia/Shanghai";
    systemd.network.wait-online.enable = false;

    # 允许非自由软件
    nixpkgs.config.allowUnfree = true;

    # Proxmox LXC 特定设置
    proxmoxLXC = {
        privileged = true;
        manageNetwork = true;
        manageHostName = false;
    };

    # 控制台配置
    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
        earlySetup = true;
    };

    # 硬件加速配置
    hardware = {
        enableAllFirmware = true;
        
        # OpenGL 和图形配置
        opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime
            vpl-gpu-rt
            intel-vaapi-driver
            vaapiIntel
        ];
        };
        
        # Intel CPU 支持
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

    # X服务器配置
    services.xserver = {
        enable = true;
        videoDrivers = [ "modesetting" ];
        
        # KDE Plasma 配置
        displayManager = {
        sddm.enable = true;
        sddm.settings = {
            General = {
            DisplayServer = "x11";
            };
            X11 = {
            EnableHiDPI = true;
            };
        };
        # 禁用 Wayland 会话
        defaultSession = "plasma";
        };
        
        # 使用 Plasma 6
        desktopManager.plasma6 = {
        enable = true;
        useQtScaling = true;
        };
        
        # 设备配置 - 启用 DRI3
        deviceSection = ''
        Option "DRI" "3"
        Option "TearFree" "true"
        Option "AccelMethod" "glamor"
        '';
        
        # 禁用 systemd-logind
        enableSystemdLogind = false;
        
        # 会话命令设置
        displayManager.sessionCommands = ''
        export XDG_SESSION_TYPE=x11
        export KDEWM=kwin_x11
        export QT_QPA_PLATFORM=xcb
        systemctl --user mask systemd-logind.service || true
        systemctl --user stop systemd-logind.service || true
        '';
    };

    # 远程桌面
    services.xrdp = {
        enable = true;
        defaultWindowManager = "startplasma-x11";
        openFirewall = true;
        
        # XRDP 配置
        extraConfig = ''
        [Globals]
        max_bpp=32
        use_compression=yes
        allow_channels=true
        allow_multimon=true
        
        [Xorg]
        param=-nologind
        param=-novtswitch
        param=-dpi 96
        '';
    };

    # 自定义 Xorg 配置文件
    environment.etc."X11/xrdp/xorg.conf" = {
        text = ''
        Section "ServerFlags"
            Option "DontVTSwitch" "true"
            Option "AutoAddDevices" "false"
            Option "AutoEnableDevices" "false" 
            Option "DontZap" "true"
        EndSection

        Section "Module"
            Load "glx"
            Load "dri3"
        EndSection

        Section "InputDevice"
            Identifier "Xorg Mouse"
            Driver "void"
        EndSection

        Section "InputDevice"
            Identifier "Xorg Keyboard"
            Driver "void"
        EndSection

        Section "Device"
            Identifier "Intel Graphics"
            Driver "modesetting"
            Option "AccelMethod" "glamor"
            Option "DRI" "3"
            Option "TearFree" "true"
            Option "TripleBuffer" "true"
        EndSection
        
        Section "Screen"
            Identifier "Screen0"
            Device "Intel Graphics"
        EndSection
        '';
        mode = "0644";
    };

    # Shell 配置
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

    # 环境变量和系统包
    environment = {
        variables = {
        LIBVA_DRIVER_NAME = "iHD";
        MESA_LOADER_DRIVER_OVERRIDE = "iris";
        KDEWM = "kwin_x11";
        QT_QPA_PLATFORM = "xcb";
        LIBGL_DEBUG = "verbose";
        };
        
        systemPackages = with pkgs; [
        # 基本工具
        vim git wget curl sudo
        
        # 系统监控和维护
        htop
        intel-gpu-tools
        glxinfo
        libva-utils
        vulkan-tools
        pciutils
        mesa
        libdrm
        
        # KDE 工具
        plasma5Packages.kde-cli-tools
        plasma5Packages.kdeplasma-addons
        
        # 浏览器
        firefox
        ];
    };

    # 用户配置
    users = {
        groups.knb = { gid = lib.mkForce 987; };
        
        users = {
        root = {
            password = "passpapa";
        };
        
        knb = {
            isNormalUser = true;
            group = "knb";
            home = "/home/knb";
            description = "Primary User";
            extraGroups = [ "wheel" "networkmanager" "video" "render" "input" ];
            shell = pkgs.zsh;
            password = "knbbnk";
        };
        };
    };

    # 网络配置
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

    # 国际化
    i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "zh_CN.UTF-8/UTF-8"
        ];
        inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
            fcitx5-chinese-addons
            fcitx5-rime
        ];
        };
    };

    # 字体配置
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

    # 安全配置
    security = {
        pam.services.sshd.allowNullPassword = false;
        sudo = {
        enable = true;
        wheelNeedsPassword = true;
        };
        
        # 允许 Xorg 直接访问硬件
        polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id.indexOf("org.freedesktop.login1.") == 0) {
            return polkit.Result.YES;
            }
        });
        '';
    };

    # 设备权限规则
    services.udev.extraRules = ''
        SUBSYSTEM=="drm", ACTION=="add|change", ATTR{accessible}="yes"
    '';

    # 在启动时修复 GPU 权限
    system.activationScripts.fixGpuPermissions = ''
        chmod 666 /dev/dri/card* /dev/dri/render* || true
    '';

    # SSH 服务
    services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = false;
        X11Forwarding = false;
        };
    };

    # 系统服务设置
    systemd = {
        additionalUpstreamSystemUnits = [ "systemd-udev-trigger.service" ];
        
        services.systemd-rfkill = {
        wantedBy = lib.mkForce [];
        enable = false;
        };
    };
}