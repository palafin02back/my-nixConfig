{config, lib, pkgs, ...}: {
  security = {
    # SSH security baseline
    pam.services.sshd.allowNullPassword = false;
    
    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

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

  # System limits and optimizations
  systemd = {
    services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    network.wait-online.enable = false;  # Accelerate boot time
    extraConfig = ''
      DefaultLimitNOFILE=102400
    '';
  };
}