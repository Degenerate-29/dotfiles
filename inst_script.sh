#!/bin/bash

echo "Starting Ubuntu Environment Restoration..."

# 1. Update system and install APT packages
echo "Installing APT packages..."
sudo apt update
# Read apt-packages.txt, ignoring empty lines, and install
xargs -a apt-packages.txt sudo apt install -y

# 2. Install Snap packages
echo "Installing Snap packages..."
xargs -a snap-packages.txt -n 1 sudo snap install

# 3. Restore hidden config files
echo "Restoring core dotfiles (.zshrc, .bashrc, .vimrc, .gitconfig)..."
cp .bashrc ~/.bashrc
cp .zshrc ~/.zshrc
cp .vimrc ~/.vimrc
cp .gitconfig ~/.gitconfig

# 4. Restore Oh-My-Zsh Themes
# Copies setupx09-agnoster, concise, and no_comments versions
echo "Restoring Zsh themes..."
mkdir -p ~/.oh-my-zsh/themes
cp themes/*.zsh-theme ~/.oh-my-zsh/themes/

# 5. Restore Custom Fonts
# Copies the entire MesloLGS_NF directory to local fonts
echo "Installing MesloLGS NF fonts..."
mkdir -p ~/.local/share/fonts
cp -r font/* ~/.local/share/fonts/
fc-cache -f -v

# 6. Restore GNOME Settings & Tweaks
echo "Restoring GNOME desktop settings..."
dconf load /org/gnome/ < gnome-settings.dconf

# 7. Restore GNOME Extensions Settings and Enable Them
echo "Restoring and enabling GNOME extensions..."
dconf load /org/gnome/shell/extensions/ < gnome-extensions.dconf
xargs -a extensions-list.txt -n 1 gnome-extensions enable

# 8. Restore GNOME Terminal Profile
echo "Restoring GNOME Terminal Profile..."
dconf load /org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ < terminal-profile.dconf

# 9. Apply Wallpaper
echo "Applying Wallpaper..."
mkdir -p ~/.local/share/backgrounds
cp current-wallpaper ~/.local/share/backgrounds/
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/current-wallpaper"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/current-wallpaper"

echo "========================================"
echo "Restoration Complete! Please restart your terminal, and log out/log in to apply all GNOME changes."
