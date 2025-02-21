{config, pkgs, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-commentary
      vim-surround
      vim-fugitive
      nvim-treesitter
    ];

    extraConfig = ''
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set cursorline
      set termguicolors
      
      " Basic keymaps
      let mapleader = " "
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
    '';
  };
}