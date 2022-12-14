#!/usr/bin/env bash
FLATPAK_PROGRAMS=("com.tutanota.Tutanota" "com.github.muriloventuroso.easyssh" "com.stremio.Stremio" "com.github.tchx84.Flatseal" "eu.ithz.umftpd" "org.onlyoffice.desktopeditors" "org.gnome.Boxes")
MAIN_DIR="$(pwd)"
NIX_FILES=("hardware-configuration.nix" "configuration.nix" "home.nix")

sudo rm -r /etc/nixos/
sudo mkdir /etc/nixos/

for file in "${NIX_FILES[@]}"; do
    sudo ln -s "$MAIN_DIR/$file" "/etc/nixos/"
done

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update

for program in "${FLATPAK_PROGRAMS[@]}"; do
    flatpak install "$program" -y
done

git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
"$HOME/.emacs.d/bin/doom" install
"$HOME/.emacs.d/bin/doom" sync
rm -r "$HOME/.doom.d"

stow --target=$HOME --dir=$HOME/Projects/bkps/ --stow .dotfiles
