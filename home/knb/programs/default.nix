{config, pkgs, ...}: {
  imports = [
    ./neovim.nix
  ];

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["git" "docker" "docker-compose"];
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
      ];
    };
  };
}