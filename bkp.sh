#!/usr/bin/env bash

############################################################################
# ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ #
# ██░▄▄▀█░▄▄▀██░▄▄▀██░█▀▄██░██░██░▄▄░████░▄▄▄░██░▄▄▀██░▄▄▀█▄░▄██░▄▄░█▄▄░▄▄ #
# ██░▄▄▀█░▀▀░██░█████░▄▀███░██░██░▀▀░████▄▄▄▀▀██░█████░▀▀▄██░███░▀▀░███░██ #
# ██░▀▀░█░██░██░▀▀▄██░██░██▄▀▀▄██░███████░▀▀▀░██░▀▀▄██░██░█▀░▀██░██████░██ #
# ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ # 
############################################################################

# VARIABLES -------------------------------------------------------------------------------------------------------------

DEB_URLS_FILE="deb_urls.txt"
DIR_DEB="/tmp/deb_packages"
DIR_APPIMAGES="$HOME/appimages"
RED="\e[1;31m"
BLUE="\e[1;34m"
GREEN="\e[1;32m"
NO_COLOR="\e[0m"
MAIN_DIR="$(pwd)"
APPIMAGES_FILE="$MAIN_DIR/appimages.txt"

# REQUIREMENTS ---------------------------------------------------------------------------------------------------------

required_programs () {
    local apps 
    
    apps=(flatpak wget git  zip unzip gzip curl file build-essential procps csvkit)
    
    for app in "${apps[@]}"; do
        if [[ ! -x $(which "$app") ]]; then
            echo -e "${RED}[ERROR] - $app not installed.${NO_COLOR}"
            echo -e "${BLUE}[IN PROGRESS] - Installing $app...${NO_COLOR}"
            sudo apt install "$app" -y 
            echo -e "${GREEN}[DONE] - $app installed."
        else
            echo -e "${GREEN}[DONE] - $app already installed."
        fi
    done
}

remove_locks () {
    echo -e "${BLUE}[IN PROGRESS] - Removing locks...${NO_COLOR}"
    sudo rm /var/lib/dpkg/lock-frontend
    sudo rm /var/cache/apt/archives/lock
    echo -e "${GREEN}[DONE] - Locks removed.${NO_COLOR}"
}

add_i386_architecture () {
    echo -e "${BLUE}[IN PROGRESS] - Adding x86 architecture...${NO_COLOR}"
    sudo dpkg --add-architecture i386
    echo -e "${GREEN}[DONE] - x86 architecture added.${NO_COLOR}"
}

homebrew () {
    echo -e "${BLUE}[IN PROGRESS] - Installing Homebrew...${NO_COLOR}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -r "$HOME/.bash_profile" && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
    echo -e "${GREEN}[DONE] - Homebrew installed.${NO_COLOR}"
}

mamba () {
    echo -e "${BLUE}[IN PROGRESS] - Installing Mamba...${NO_COLOR}"
    wget -O /tmp/mambaforge.sh "https://github.com/"/home/$USER/mambaforge/condabin/conda"-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh" 
    sudo chmod +x /tmp/mambaforge.sh 
    bash /tmp/mambaforge.sh
    source "$HOME/.bashrc"
    "$HOME/mambaforge/condabin/conda" config --set auto_activate_base false
    echo -e "${GREEN}[DONE] - Mamba installed.${NO_COLOR}" 
}

remove_installed () {
    local apps_to_uninstall

    apps_to_uninstall=$(apt list --installed | grep libreoffice | cut -d "/" -f 1)
    apps_to_uninstall+=(geary gnome-calendar gnome-contacts)

    for app in "${apps_to_uninstall[@]}"; do
        echo -e "${BLUE}[IN PROGRESS] - Removing $app...${NO_COLOR}"
        sudo apt remove "$app" -y 
        echo -e "${GREEN}[DONE] - $app removed.${NO_COLOR}"
    done
}

# SYSTEM JOBS ----------------------------------------------------------------------------------------------------------

att_repos () {
    echo -e "${BLUE}[IN PROGRESS] - Updating repos...${NO_COLOR}"
    sudo apt update -y 
    echo -e "${GREEN}[DONE] - Repos updated.${NO_COLOR}"
}

upgrade () {
    echo -e "${BLUE}[IN PROGRESS] - Upgrading system...${NO_COLOR}"
    sudo apt dist-upgrade -y  
    echo -e "${GREEN}[DONE] - System upgraded.${NO_COLOR}"
}

clean () {
    echo -e "${BLUE}[IN PROGRESS] - Cleaning system...${NO_COLOR}"
    sudo apt autoclean 
    sudo apt autoremove -y 
    echo -e "${GREEN}[DONE] - System cleaned.${NO_COLOR}"
}

# READING FILES --------------------------------------------------------------------------------------------------------

reading_programs_file () {
    PROGRAMS_APT=()
    PROGRAMS_FLATPAK=()
    PROGRAMS_BREW=()
    PROGRAMS_MAMBA=()
    local file_apps="/tmp/apps.txt"

    if [[ $pc_or_laptop == "pc" ]]; then
        csvsql --query "select program,package_manager from programs" "$MAIN_DIR"/programs.csv | tail -n +2 | xargs echo | tr ' ' '\n' > "$file_apps" 
    else
        csvsql --query "select program,package_manager from programs where where_install='both'" "$MAIN_DIR"/programs.csv | tail -n +2 | xargs echo | tr ' ' '\n' > "$file_apps"
    fi

    while IFS= read -r line; do
        local str_1
        local str_2

        str_1=$(echo -e "${line%%,*}")
        str_2=$(echo -e "${line##*,}")

        if [[ $str_2 = "apt" ]]; then
            PROGRAMS_APT+=("$str_1")
        elif [[ $str_2 = "flatpak" ]]; then
            PROGRAMS_FLATPAK+=("$str_1")
        elif [[ $str_2 = "mamba" ]]; then
            PROGRAMS_MAMBA+=("$str_1")
        else
            PROGRAMS_BREW+=("$str_1")
        fi
    done < "$file_apps"
}

# INSTALLING PROGRAMS --------------------------------------------------------------------------------------------------

download_deb () {
    mkdir "$DIR_DEB"
    echo -e "${BLUE}[IN PROGRESS] - Downloading .deb packages...${NO_COLOR}"
    while IFS= read -r line; do
        wget -c "$line" -P "$DIR_DEB" 
    done < "$DEB_URLS_FILE"
    echo -e "${GREEN}[DONE] - .deb packages downloaded.${NO_COLOR}"
}

download_appimage () {
    mkdir "$DIR_APPIMAGES"
    echo -e "${BLUE}[IN PROGRESS] - Downloading Appimages...${NO_COLOR}"
    while IFS= read -r line; do
        wget -c "$line" -P "$DIR_APPIMAGES" 
    done < "$APPIMAGES_FILE"
    echo -e "${GREEN}[DONE] - Appimages downloaded.${NO_COLOR}"
}

install_deb () {
    download_deb
    echo -e "${BLUE}[IN PROGRESS] - Installing .deb packages...${NO_COLOR}"
    sudo apt install "$DIR_DEB"/*.deb 
    echo -e "${BLUE}[IN PROGRESS] - Installing dependencies...${NO_COLOR}"
    sudo apt -f install -y 
    echo -e "${GREEN}[DONE] - .deb packages installed.${NO_COLOR}"
}

install_apt () {
    wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash 
    att_repos
    for program in "${PROGRAMS_APT[@]}"; do
        echo -e "${BLUE}[IN PROGRESS] - Installing $program (apt)...${NO_COLOR}"
        sudo apt install "$program" -y 
        echo -e "${GREEN}[DONE] - $program installed.${NO_COLOR}" 
    done
}

install_flatpak () {
    for program in "${PROGRAMS_FLATPAK[@]}"; do
        echo -e "${BLUE}[IN PROGRESS] - Installing $program (flatpak)...${NO_COLOR}"
        flatpak install "$program" -y 
        echo -e "${GREEN}[DONE] - $program installed.${NO_COLOR}"
    done
}

install_brew () {
    for program in "${PROGRAMS_BREW[@]}"; do
        echo -e "${BLUE}[IN PROGRESS] - Installing $program (brew)...${NO_COLOR}"
        brew install "$program" 
        echo -e "${GREEN}[DONE] - $program installed.${NO_COLOR}"    
    done
}

install_R_packages () {
    echo -e "${BLUE}[IN PROGRESS] - Installing R dependencies...${NO_COLOR}"
    sudo apt update -qq 
    sudo apt install --no-install-recommends software-properties-common dirmngr 
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" 
    echo -e "${BLUE}[IN PROGRESS] - Installing R...${NO_COLOR}"
    sudo apt install r-base r-base-dev -y
    echo -e "${BLUE}[IN PROGRESS] - Installing libssl1.1...${NO_COLOR}"
    wget -O /tmp/http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
    sudo dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
    echo 'alias radian="$HOME/mambaforge/bin/radian"' >> "$HOME/.bashrc"
    echo 'alias r="$HOME/mambaforge/bin/radian"' >> "$HOME/.bashrc"
    echo -e "${BLUE}[IN PROGRESS] - Installing R packages...${NO_COLOR}"
    Rscript r_packages.R
    echo -e "${GREEN}[DONE] - R packages installed.${NO_COLOR}"
}

install_python_packages () {
    echo -e "${BLUE}[IN PROGRESS] - Installing Python packages...${NO_COLOR}"
    /home/phrmendes/mambaforge/condabin/mamba install "${PROGRAMS_MAMBA[@]}" -y 
    echo -e "${GREEN}[DONE] - Python packages installed.${NO_COLOR}"
}

install_docker () {
    echo -e "${BLUE}[IN PROGRESS] - Installing Docker...${NO_COLOR}"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list &> /dev/null
    att_repos
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 
    sudo groupadd docker
    sudo usermod -aG docker phrmendes 
    echo -e "${GREEN}[DONE] - Docker installed.${NO_COLOR}"
}

setup_fonts () {
    echo -e "${BLUE}[IN PROGRESS] - Setting up fonts...${NO_COLOR}"
    mkdir -p "$HOME"/.local/share/fonts/NerdFonts
    unzip -d "/tmp/NerdFonts" "$MAIN_DIR/NerdFonts.zip"
    cp -r /tmp/NerdFonts/* "$HOME/.local/share/fonts/NerdFonts"
    fc-cache -f -v "$HOME"/.local/share/fonts/
    echo -e "${GREEN}[DONE] - Fonts set up.${NO_COLOR}"
}

setup_fish () {
    echo -e "${BLUE}[IN PROGRESS] - Installing fish...${NO_COLOR}"
    "/home/$USER/mambaforge/condabin/conda" init fish
    chmod +x "$MAIN_DIR/fish_setup.fish"
    "/home/linuxbrew/.linuxbrew/bin/fish" "$MAIN_DIR/fish_setup.fish"
    echo -e "${GREEN}[DONE] - Fish set up.${NO_COLOR}"
}

setup_vscode () {
    echo -e "${BLUE}[IN PROGRESS] - Setting up VSCode...${NO_COLOR}"
    wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" 
    sudo apt install /tmp/vscode.deb
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    mkdir -p "$HOME"/.config/nvim
    mkdir -p "$HOME"/.config/Code/User
    cp "$MAIN_DIR"/init.vim "$HOME"/.config/nvim
    cp "$MAIN_DIR"/*.json "$HOME"/.config/Code/User
    echo -e "${GREEN}[DONE] - VSCode set up.${NO_COLOR}" 
}

setup_lunarvim () {
    echo -e "${BLUE}[IN PROGRESS] - Setting up LunarVim...${NO_COLOR}" 
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.bashrc"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME/.bashrc"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    nvm install 16
    echo 'nvm use 16 &> /dev/null' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
    mkdir -p "$HOME"/.config/lvim
    cp "$MAIN_DIR"/config.lua "$HOME"/.config/lvim
    echo 'lvim="$HOME/.local/bin/lvim"' >> "$HOME/.bashrc"
    echo -e "${GREEN}[DONE] - LunarVim set up.${NO_COLOR}"
}

# EXECUTION ------------------------------------------------------------------------------------------------------------

read -r -p "PC or laptop? (pc/lp): " pc_or_laptop

att_repos
required_programs
remove_locks
add_i386_architecture
att_repos
upgrade
remove_installed
homebrew
mamba
reading_programs_file
download_appimage
download_deb
install_deb
install_apt
install_brew

if [[ $pc_or_laptop == "lp" ]]; then
    setup_lunarvim
else
    install_flatpak
    install_docker
    setup_vscode
fi

install_python_packages
setup_fonts
clean
setup_fish

read -r -p "Install R packages? (y/n): " install_r
if [[ $install_r == "y" ]]; then install_R_packages; fi

echo -e "${GREEN}[DONE] - Setup finished.${NO_COLOR}"
