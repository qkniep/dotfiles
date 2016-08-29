#!/bin/bash
# This script sets up everything needed for my Linux configuration.


# --------------------------------------------------------------
# Variables
# --------------------------------------------------------------

dir=~/dotfiles         # dotfiles directory
olddir=~/dotfiles_old  # backup directory
files=".bashrc .bash_aliases .bash_functions .vimrc .ssh/config"
#install="apt install"


# --------------------------------------------------------------
# Dotfiles
# --------------------------------------------------------------

mkdir -p $olddir
cd $dir
for file in $files; do
	newfile=${file//.}
	newfile=${newfile//\//_}
	mv ~/$file $olddir/$newfile  # move old dotfiles
	ln -s $dir/$newfile ~/$file  # create symlinks
done


# --------------------------------------------------------------
# Software
# --------------------------------------------------------------

add-apt-repository ppa:noobslab/themes  # for flatabulous-theme & ultra-flat-icons

apt update

apt install flatabulous-theme  # flat theme for Unity
apt install ultra-flat-icons   # flat icons (default: blue)
#apt install ultra-flat-icons-orange
#apt install ultra-flat-icons-green
apt install vim                # text editor
apt install git                # version control
apt install unp                # archive unpacker
apt install weechat            # IRC client
apt install mpsyt              # youtube CLI audio-player
apt install cmatrix            # matrix animation
apt install tty-clock          # terminal clock


# --------------------------------------------------------------
# Github
# --------------------------------------------------------------

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim     # vim plugin manager
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell  # base16 shell colors


# --------------------------------------------------------------
# GSettings
# --------------------------------------------------------------

# TODO download wallpaper
#gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/4HPEcJ8.jpg
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.desktop.input-sources xkb-options ['caps:escape']
gsettings set org.gnome.desktop.interface gtk-theme "Flatabulous"
gsettings set org.gnome.desktop.interface icon-theme "Ultra-Flat"
# TODO install powerline fonts
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono for Powerline 12"
gsettings set org.gnome.desktop.peripherals.mouse speed -0.9
gsettings set org.gnome.desktop.wm.preferences ation-right-click-titlebar "minimize"
gsettings set org.gnome.desktop.wm.preferences theme "Flatabulous"

gsettings set com.canonical.indicator.datetime show-calendar true
gsettings set com.canonical.indicator.datetime show-date true
gsettings set com.canonical.indicator.datetime show-day true
gsettings set com.canonical.indicator.datetime show-seconds true
gsettings set com.canonical.indicator.datetime show-year false
