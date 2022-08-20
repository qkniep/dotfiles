#!/bin/bash

# This script sets up a development environment from scratch.
# It should be used when setting up a new machine.


# ==== Utility Functions =======================================

RED='\u001b[31m'
GRN='\u001b[32m'
YEL='\u001b[33m'
BLU='\u001b[34m'
RST='\u001b[0m'

pinfo () {
  echo -e "$BLU$1$RST"
}

prompt () {
  echo -n -e "$BLU$1$RST"
}

psuccess () {
  echo -e "$GRN$1$RST"
}

pwarn () {
  echo -e "$YEL$1$RST"
}

perr () {
  echo -e "$RED$1$RST"
}

find_package_manager () {
  PACKAGE_MANAGERS='brew pacman'
  for PM in $PACKAGE_MANAGERS; do
    if [ $( which "$PM" ) ] ; then
      echo "$PM"
    fi
  done
  echo ""
}


# ==== Global Variable =========================================

PROMPT="[bootstrap]"
BACKUP_DIR="~/dotfiles_old"
PROJECTS_PATH="~/projects"

FILES=".zshrc"


# ==== Create Projects Directory ===============================

prompt "$PROMPT Where should I create your projects folder? ($PROJECTS_PATH) "
read path
path=${path:-$PROJECTS_PATH}
mkdir -p "$path"


# ==== Link Dotfiles ===========================================

pinfo "$PROMPT Symlinking the files in this repo to the home directory."
prompt "$PROMPT Proceed? ([y]/n) "
read resp
if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
  pwarn "$PROMPT Symlinking skipped."
else
  mkdir -p "$BACKUP_DIR"
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
  prompt "$PROMPT Install homebrew? ([y]/n) "
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
    pwarn "$PROMPT Tool installtion skipped."
  else
    pinfo "$PROMPT Installing useful tools using $PM. This may take a while..."
    sh "setup/$PM.sh"
    psuccess "$PROMPT Tool installation completed."
  fi
fi
