{config, pkgs, ...}: {
  imports = [
    ./neovim.nix
  ];

  programs = {
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