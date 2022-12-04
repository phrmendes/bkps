{ config, pkgs, ... }:

let
  user = "phrmendes";
in {
  home = {
    stateVersion = "22.05";
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = with pkgs;
    let
      my-r-packages = rWrapper.override{
        packages = with rPackages; [
          tidyverse
          data_table
          pbapply
          tinytex
          quarto
          styler
          lintr
          zip
          fs
          janitor
          zoo
          curl
        ];
      };
    in
    [
      # TERMINAL PROGRAMS
      btop
      pandoc
      bat
      btop
      gh
      lazygit
      ripgrep
      fd
      sd
      tealdeer
      exa
      shellcheck
      ncdu
      starship
      quarto
      micromamba
      direnv
      niv
      lorri
      ranger
      # PACKAGE MANAGERS
      cargo
      go
      nodejs
      my-r-packages
      # APPS
      emacs
      filezilla
      solaar
      bitwarden
      pcloud
      zotero
      spotify
      fragments
      kooha
      podman
      zathura
      cmdstan
      # OTHERS
      texlive.combined.scheme-minimal
    ];
  };

  programs = {
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    fish = {
      enable = true;
      shellAliases = {
        mkdir = "mkdir -p";
        ls = "exa --icons";
        cat = "bat";
        nv = "nvim";
        lg = "lazygit";
      };
      shellAbbrs = {
        stow_dotfiles = "stow --target=$HOME --dir=$HOME/Projects/bkps/ --stow .dotfiles";
        mamba = "micromamba";
      };
      shellInit = ''
        fish_add_path "$HOME/.emacs.d/bin"
        set -gx MAMBA_EXE "/home/phrmendes/.nix-profile/bin/micromamba"
        set -gx MAMBA_ROOT_PREFIX "/home/phrmendes/micromamba"
        eval "/home/phrmendes/.nix-profile/bin/micromamba" shell hook --shell fish --prefix "/home/phrmendes/micromamba" | source
      '';
     };
    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        vim-fish
        vim-easymotion
        vim-commentary
        lightline-vim
        nerdcommenter
        ack-vim
        vim-gitgutter
        auto-pairs
        fzf-vim
        vim-polyglot
      ];
      extraConfig = ''
        set background=dark
        set clipboard=unnamedplus
        set completeopt=noinsert,menuone,noselect
        set cursorline
        set hidden
        set inccommand=split
        set mouse=a
        set number
        set relativenumber
        set splitbelow splitright
        set title
        set ttimeoutlen=0
        set wildmenu
        set expandtab
        set shiftwidth=2
        set tabstop=2
      '';
      vimAlias = true;
      vimdiffAlias = true;
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
    };
    home-manager.enable = true;
  };

    xdg.enable = true;
    xdg.mime.enable = true;
    targets.genericLinux.enable = true;
}
