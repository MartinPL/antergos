#!/usr/bin/env bash
echo "Chrooted in the new system, running as $(whoami)"

# User setup
useradd -mG wheel antergos
usermod -c "Password // \"antergos\"" antergos
usermod -p $(echo "antergos" | openssl passwd -6 -stdin) antergos
usermod -p $(echo "antergos" | openssl passwd -6 -stdin) root
chsh -s /usr/bin/zsh antergos

# Install Jade GUI
flatpak install -y --noninteractive /usr/share/jade-gui/jade-gui.flatpak

# Desktop icon for Jade's GUI
mkdir -p /home/antergos/Desktop
cp \
  /var/lib/flatpak/exports/share/applications/al.getcryst.jadegui.desktop \
  /home/antergos/Desktop/Install.desktop

# Disable auto screen lock
mkdir -p /home/antergos/.config/autostart
echo "[Desktop Entry]
Name=Deactive lock screen
Comment=Deactive the gnome lock screen in the live session
Type=Application
Icon=nautilus
Exec=sh -c \"gsettings set org.gnome.desktop.screensaver lock-enabled false\"" > /home/antergos/.config/autostart/no-lock-screen.desktop

# Set default session to Onyx
echo "[User]
Session=onyx
Icon=/var/lib/AccountsService/icons/antergos
SystemAccount=false" > /var/lib/AccountsService/users/antergos

# Jade-GUI Autostart
cp \
  /var/lib/flatpak/exports/share/applications/al.getcryst.jadegui.desktop \
  /home/antergos/.config/autostart

# Permissions for antergos user
chown -R antergos:antergos /home/antergos/
chmod +x /home/antergos/.config/autostart/*.desktop

# Services
systemctl enable vmtoolsd
systemctl enable vmware-vmblock-fuse
systemctl enable NetworkManager
systemctl enable reflector
systemctl enable gdm

# Mirrorlist
reflector > /etc/pacman.d/mirrorlist

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

echo "Configured the system. Exiting chroot."
