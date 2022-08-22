#!/bin/bash

# This script sets up a development environment from scratch.
# It should be used when setting up a new machine.

source utility.sh


# ==== Global Variables ========================================

PROMPT="[bootstrap]"
BACKUP_DIR="$HOME/dotfiles_old"
PROJECTS_PATH="$HOME/projects"

FILES=""


if [ "$EUID" = '0' ] ; then
  perr 'You should not run this script as root!'
  exit 1
fi

# ==== Create Projects Directory ===============================

prompt "$PROMPT Where should I create your projects folder? ($PROJECTS_PATH) "
read path
path=${path:-$PROJECTS_PATH}
mkdir -p "$path"


# ==== Link Dotfiles ===========================================

pinfo "$PROMPT Symlinking the files in this repo to the home directory."
prompt "$PROMPT Proceed? [Y/n] "
read resp
if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
  pwarn "$PROMPT Symlinking skipped."
else
  mkdir -p "$BACKUP_DIR"
  mkdir -p "$HOME/.config/nvim"
  ln -sv "$PWD/nvim/init.lua" "$HOME/.config/nvim/init.lua"
  ln -sv "$PWD/nvim/lua" "$HOME/.config/nvim/lua"
  for file in $FILES; do
    mv "$HOME/$file" "$BACKUP_DIR/$file"
    ln -sv "$PWD/$file" "$HOME"
  done
  psuccess "$PROMPT Symlinking completed."
fi


# ==== Install Tools ===========================================

pinfo "$PROMPT Installing useful utilities using your package manager."
PM=$(find_package_manager)

# on macOS, install homebrew if not found
if [ "$PM" = "" -a $(uname) = "Darwin" ] ; then
  pwarn "$PROMPT No package manager found."
  prompt "$PROMPT Install homebrew? [Y/n] "
  read resp
  if [ "$resp" != 'n' -a "$resp" != 'N' ] ; then
    pinfo "$PROMPT Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    PM="brew"
  fi
fi

if [ "$PM" = "" ] ; then
  perr "$PROMPT Skipping tool installation because none of the supported package managers was found."
  pinfo "$PROMPT Currently supported are: $PACKAGE_MANAGERS"
else
  pinfo "$PROMPT Detected package manager: $PM"
  prompt "$PROMPT Proceed installing packages with $PM? [Y/n] "
  read resp
  if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
    pwarn "$PROMPT Tool installation skipped."
  else
    pinfo "$PROMPT Installing useful tools using $PM. This may take a while..."
    cd setup
    bash "./$PM.sh"
    psuccess "$PROMPT Tool installation completed."
  fi
fi
