#!/bin/bash
# This script sets up everything needed for my Linux configuration.


# --------------------------------------------------------------
# Variables
# --------------------------------------------------------------

dir=~/dotfiles         # dotfiles directory
olddir=~/dotfiles_old  # backup directory
files=".bashrc .bash_aliases .bash_functions .vimrc .ssh/config"

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

apt install vim        # text editor
apt install git        # version control
apt install unp        # archive unpacker
apt install mpsyt      # youtube CLI audio-player
apt install weechat    # IRC client
apt install cmatrix    # matrix animation
apt install ttu-clock  # terminal clock


# --------------------------------------------------------------
# Github
# --------------------------------------------------------------

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim     # vim plugin manager
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell  # base16 shell colors
