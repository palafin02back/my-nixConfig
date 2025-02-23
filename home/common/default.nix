{config, pkgs, ...}: {
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        ".." = "cd ..";
      };
    };

    git = {
      enable = true;
      userName = "palafin";
      userEmail = "palafin@gear4ai.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    tmux = {
      enable = true;
      shortcut = "a";
      terminal = "screen-256color";
    };
  };
}