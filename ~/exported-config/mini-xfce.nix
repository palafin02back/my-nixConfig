{ config, modulesPath, pkgs, lib, ... }:

{
    imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
    
    # 内核配置
    boot.initrd.kernelModules = [ "i915" ];
    boot.kernelParams = [ "drm" "i915.force_probe=46d1" ];
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # 基本系统设置
    system.stateVersion = "24.11";
    nix.settings.experimental-features = [ "nix-command" ];
    nix.settings.sandbox = false;
    
    # 允许非自由软件
    nixpkgs.config.allowUnfree = true;

    # Proxmox LXC 设置
    proxmoxLXC = {
        privileged = true;
        manageNetwork = true;
        manageHostName = false;
    };

    # 硬件加速配置
    hardware = {
        enableAllFirmware = true;
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
        };
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

    # X服务器配置 - 替换为 XFCE
    services.xserver = {
        enable = true;
        videoDrivers = [ "modesetting" ];
        
        # 启用 XFCE 桌面环境
        desktopManager.xfce.enable = true;
        displayManager.lightdm.enable = true;
        
        # 添加 GPU 加速相关配置
        deviceSection = ''
            Option "DRI" "3"
            Option "TearFree" "true"
        '';
    };

    # 远程桌面
    services.xrdp = {
        enable = true;
        defaultWindowManager = "startxfce4";
        openFirewall = true;
    };

    # 环境变量
    environment = {
        variables = {
            LIBVA_DRIVER_NAME = "iHD";
            MESA_LOADER_DRIVER_OVERRIDE = "iris";
        };
        
        # 系统包
        systemPackages = with pkgs; [
            # 测试工具
            glxinfo
            libva-utils
            intel-gpu-tools
            mesa
            libdrm
            
            # 基本工具
            vim
            curl
            sudo
            
            # XFCE 额外工具
            xfce.thunar-archive-plugin
            xfce.thunar-volman
        ];
    };

    # 用户配置
    users.groups.knb = { gid = lib.mkForce 987; };
    programs.zsh.enable = true;
    users.users = {
        root = {
            password = "passpapa";
        };

        knb = {
            isNormalUser = true;
            group = "knb";
            home = "/home/knb";
            description = "Primary User";
            extraGroups = [ "wheel" "video" "render" "input" ];
            shell = pkgs.zsh;
            password = "knbbnk";
        };
    };

    # 网络配置
    networking = {
        useDHCP = false;
        interfaces.eth0 = {
            ipv4.addresses = [{
                address = "192.168.31.101";
                prefixLength = 24;
            }];
        };
        defaultGateway = "192.168.31.250";
        nameservers = [ "192.168.31.250" ];
    };

    # SSH 服务配置
    services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
        };
    };

    # 系统服务设置
    systemd.services.systemd-rfkill = {
        wantedBy = lib.mkForce [];
        enable = false;
    };

    # 激活脚本
    system.activationScripts.checkGpuDevices = ''
        echo "检查 GPU 设备:"
        ls -la /dev/dri/
    '';
}
