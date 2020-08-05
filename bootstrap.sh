#!/bin/sh
# This script sets up a development environment from scratch and should be used
# when setting up a new machine.

PROMPT="[bootstrap]"
BACKUP_DIR="~/dotfiles_old"
PROJECTS_PATH="~/projects"

FILES=".zshrc"

# ==== Create Projects Directory ===============================

printf "$PROMPT Where should I create your projects folder? ($PROJECTS_PATH) "
read path
path=${path:-$PROJECTS_PATH}
mkdir -p "$path"

# ==== Link Dotfiles ===========================================

echo "$PROMPT Symlinking the files in this repo to the home directory."
printf "$PROMPT Proceed? ([y]/n) "
read resp
if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
  echo "$PROMPT Symlinking skipped."
else
  mkdir -p "$BACKUP_DIR"
  for file in $FILES; do
    mv "$HOME/$file" "$BACKUP_DIR/$file"
    ln -sv "$PWD/$file" "$HOME"
  done
  echo "$PROMPT Symlinking completed."
fi

# ==== Install Tools ==========================================

echo "$PROMPT Installing useful utilities using your package manager."
PM=$(find_package_manager)

# on macOS, install homebrew if not found
if [ "$PM" = "" -a $(uname) = "Darwin" ] ; then
  echo "$PROMPT No package manager found."
  printf "$PROMPT Install homebrew? ([y]/n) "
  read resp
  if [ "$resp" != 'n' -a "$resp" != 'N' ] ; then
    echo "$PROMPT Installing homebrew..."
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    PM="brew"
  fi
fi

if [ "$PM" = "" ] ; then
  echo "$PROMPT Skipping tool installation because none of the supported package managers was found."
  echo "$PROMPT Currently supported are: $PACKAGE_MANAGERS"
else
  echo "$PROMPT Detected package manager: $PM"
  printf "$PROMPT Proceed? ([y]/n) "
  read resp
  if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
    echo "$PROMPT Tool installtion skipped."
  else
    echo "$PROMPT Installing useful tools using $PM. This may take a while..."
    sh "setup/$PM.sh"
    echo "$PROMPT Tool installation completed."
  fi
fi

# Install vim-plug plugin manager for neovim.
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Download Base16 shell color theme.
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

find_package_manager () {
  PACKAGE_MANAGERS='brew pacman apt'
  for PM in $PACKAGE_MANAGERS; do
    if [ $( which "$PM" ) ] ; then
      return "$PM"
    fi
  done
  return ""
}
