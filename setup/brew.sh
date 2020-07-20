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

brew cleanup
