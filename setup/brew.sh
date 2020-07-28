#! /bin/sh

brew update
brew upgrade

brew install coreutils
brew install binutils

# Install more recent versions of some macOS tools.
brew install gnu-sed --with-default-names
brew install wget --with-iri
brew install grep
brew install openssh
brew install gmp

brew install git
brew install git-lfs
brew install neovim
brew install ripgrep
brew install imagemagick --with-webp

brew install starship  # command prompt

printf "$PROMPT Do you want to set up Python? ([y]/n) "
read resp
if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
  echo "$PROMPT Python setup skipped."
else
  brew install pyenv
  pyenv install-latest
  pip install pylint
  echo "$PROMPT Python environment set up successfully."
fi

printf "$PROMPT Do you want to set up Rust? ([y]/n) "
read resp
if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
  echo "$PROMPT Rust setup skipped."
else
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup component add rustfmt
  rustup component add clippy
  echo "$PROMPT Rust environment set up successfully."
fi

brew cleanup
