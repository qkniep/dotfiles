#!/bin/sh
# This script sets up everything needed for this *nix configuration.


# --------------------------------------------------------------
# Variables
# --------------------------------------------------------------

dir=~/dotfiles         # dotfiles directory
olddir=~/dotfiles_old  # backup directory
files=".bashrc .bash_aliases .bash_functions .vimrc .ssh/config"

pre_install="apt update"
install="apt install"
#pre_install="pacman -Syu"
#install="pacman -S"
#pre_install="brew update"
#install="brew install"


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

$install git
$install curl
$install wget
$install vim
$install unp                # archive unpacker
$install weechat            # IRC client
$install mpsyt              # youtube CLI audio-player


# --------------------------------------------------------------
# Github
# --------------------------------------------------------------

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim     # vim plugin manager
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell  # base16 shell colors
