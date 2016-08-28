#!/bin/bash
# This script installs everything needed for my Linux configuration

########## Variables

dir=~/dotfiles         # dotfiles directory
olddir=~/dotfiles_old  # old dotfiles backup directory
# list of files/folders to symlink in
files="bashrc bash_aliases vimrc"
homedir

##########

# create dotfiles_old in home
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# move old dotfiles to dotfiles_old + create symlinks
for file in $files; do
	echo "Moving any existing dotfiles from ~ to $olddir"
	mv ~/.$file ~/dotfiles_old/
	echo "Creating symlink to $file in home directory."
	ln -s $dir/$file ~/.$file
done

##########

echo "Installing vim and git"
apt install vim
apt install git
echo "done"

##########

echo "Installing Vundle"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo "done"

##########

# install base16 shell colors
echo "Installing base16 shell colors from github.com/chriskempson/base16-shell"
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
echo "done"
