
{ config, modulesPath, pkgs, lib, ... }:

{
    imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
    boot.initrd.kernelModules = [ "i915" ];
    boot.kernelParams = [ "drm" "i915.force_probe=46d1" ];
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # 确保 systemd-logind 在 modprobe@drm.service 之后启动
    systemd.services.systemd-logind = {
        wants = [ "modprobe@drm.service" ];
        requires = [ "modprobe@drm.service" ];
        after = [ "modprobe@drm.service" "systemd-udevd.service" ];
    };
    # 基本系统设置
    system.stateVersion = "24.11";
    nix.settings.experimental-features = [ "nix-command" ];
    time.timeZone = "Asia/Shanghai";
    nix.settings = { sandbox = false; };
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
        # intelgpu.vaapiDriver = "intel-media-driver";
        # 图形和 OpenGL 配置
        graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                intel-media-driver
                intel-compute-runtime
                vpl-gpu-rt
                intel-vaapi-driver
                vaapiIntel
            ];
            # extraPackages32 = with pkgs; [
            #     intel-media-driver.i686
            #     intel-vaapi-driver.i686
            # ];
        };
        
        # 添加 Intel CPU 支持
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

    # X服务器配置
    services.xserver = {
        enable = true;
        videoDrivers = [ "modesetting" ];  # 仅使用 modesetting 驱动
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
    };

    # 远程桌面
    services.xrdp = {
        enable = true;
        defaultWindowManager = "gnome-session";
        openFirewall = true;
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

    # 环境变量
    environment = {
        variables = {
            LIBVA_DRIVER_NAME = "iHD";
            MESA_LOADER_DRIVER_OVERRIDE = "iris";
        };
        # etc."X11/xrdp/xorg.conf" = {
        #     text = ''
        #         Section "ServerFlags"
        #         Option "DontVTSwitch" "true"
        #         Option "AutoAddDevices" "false"
        #         Option "AutoEnableDevices" "false" 
        #         Option "DontZap" "true"
        #         EndSection

        #         Section "InputDevice"
        #         Identifier "Xorg Mouse"
        #         Driver "void"
        #         EndSection

        #         Section "InputDevice"
        #         Identifier "Xorg Keyboard"
        #         Driver "void"
        #         EndSection

        #         Section "Device"
        #         Identifier "Card0"
        #         Driver "modesetting"
        #         Option "AccelMethod" "sna"
        #         Option "TearFree" "true"
        #         Option "DRI" "3"
        #         EndSection
        #     '';
        #     mode = "0644";
        #};
        # 系统包
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
            
            # 浏览器
            firefox
        ];
    };

    # 用户组和用户配置
    users.groups = {
        knb = {gid = lib.mkForce 987;};
    };

    users.users = {
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
        type = "ibus";
        ibus.engines = with pkgs.ibus-engines; [
            libpinyin
            rime
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
    };

    # 允许Xorg直接访问硬件
    security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.login1.") == 0) {
        return polkit.Result.YES;
        }
    });
    '';

    services.xserver.displayManager.sessionCommands = '''';

    services.udev.extraRules = ''
        SUBSYSTEM=="drm", ACTION=="add|change", ATTR{accessible}="yes"
    '';
    # 启用 systemd-logind 和 udev 调试日志
    systemd.services.systemd-logind.environment = {
        SYSTEMD_LOG_LEVEL = "debug";
    };
    services.udev.extraConfig = ''
        udev_log="debug"
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

    systemd.additionalUpstreamSystemUnits = [ "systemd-udev-trigger.service" ];

    systemd.services.systemd-rfkill = {
        wantedBy = lib.mkForce [];
        enable = false;
    };
} 