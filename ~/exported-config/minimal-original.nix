{ config, modulesPath, pkgs, lib, ... }:

{
    imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
    
    # 内核配置 - 与原配置一致
    boot.initrd.kernelModules = [ "i915" ];
    boot.kernelParams = [ "drm" "i915.force_probe=46d1" ];
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # 基本系统设置
    system.stateVersion = "24.11";
    nix.settings.experimental-features = [ "nix-command" ];
    nix.settings.sandbox = false;
    
    # 允许非自由软件
    nixpkgs.config.allowUnfree = true;

    # Proxmox LXC 设置 - 与原配置一致
    proxmoxLXC = {
        privileged = true;
        manageNetwork = true;
        manageHostName = false;
    };

    # 硬件加速配置 - 使用原配置的 hardware.graphics
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

    # X服务器配置 - 与原配置保持一致
    services.xserver = {
        enable = true;
        videoDrivers = [ "modesetting" ];
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
    };

    # 远程桌面 - 与原配置一致
    services.xrdp = {
        enable = true;
        defaultWindowManager = "gnome-session";
        openFirewall = true;
    };

    # 环境变量 - 与原配置一致
    environment = {
        variables = {
            LIBVA_DRIVER_NAME = "iHD";
            MESA_LOADER_DRIVER_OVERRIDE = "iris";
        };
        
        # 仅保留测试所需的包
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
        ];
    };

    # 用户配置 - 与原配置一致
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

    # 网络配置 - 保持最小必要设置
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

    # 简化 SSH 服务配置
    services.openssh = {
        enable = true;
            openFirewall = true;
            settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
        };
    };

    # 保留原配置的其他系统服务设置
    # systemd.additionalUpstreamSystemUnits = [ "systemd-udev-trigger.service" ];
    
    systemd.services.systemd-rfkill = {
        wantedBy = lib.mkForce [];
        enable = false;
    };

    # 添加一个简单的激活脚本来检查 GPU 设备
    system.activationScripts.checkGpuDevices = ''
        echo "检查 GPU 设备:"
        ls -la /dev/dri/
    '';
}