#!/usr/bin/env bash

make_aur() {
    cd /tmp
    git clone https://aur.archlinux.org/$1.git
    chown -R nobody $1
    cd $1
    sudo -u nobody makepkg
    mv  -v /tmp/$1/*.pkg.tar.zst /home/custompkgs/
}

echo "Chrooted in the new system, running as $(whoami)"

# User setup
useradd -mG wheel antergos
usermod -c "Password // \"antergos\"" antergos
usermod -p $(echo "antergos" | openssl passwd -6 -stdin) antergos
usermod -p $(echo "antergos" | openssl passwd -6 -stdin) root
chsh -s /usr/bin/zsh antergos

# Disable auto screen lock
mkdir -p /home/antergos/.config/autostart
echo "[Desktop Entry]
Name=Deactive lock screen
Comment=Deactive the gnome lock screen in the live session
Type=Application
Icon=nautilus
Exec=sh -c \"gsettings set org.gnome.desktop.screensaver lock-enabled false\"" > /home/antergos/.config/autostart/no-lock-screen.desktop

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

# makepkg
pacman -Sy
pacman -S devtools git --noconfirm

# pamac-aur
pacman -S itstool vala asciidoc meson ninja gobject-introspection libappindicator-gtk3 dbus-glib vte3 archlinux-appstream-data appstream-glib --noconfirm
make_aur "libpamac-aur"
pacman -U /home/custompkgs/libpamac-aur-*.pkg.tar.zst --noconfirm
make_aur "pamac-aur"

# add local repo and install all his packages
echo '
[custompkgs]
Server = file:///home/custompkgs
' >> /etc/pacman.conf
repo-add /home/custompkgs/custompkgs.db.tar.gz /home/custompkgs/*.pkg.tar.zst
pacman -Sy
pacman -S `pacman -Slq custompkgs` --noconfirm

# Cnchi Autostart
cp /usr/share/applications/cnchi.desktop /home/antergos/.config/autostart

echo "Configured the system. Exiting chroot."