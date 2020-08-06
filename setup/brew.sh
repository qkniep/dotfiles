#! /bin/sh

prompt_lang_install () {
  printf "$PROMPT Do you want to set up $1? ([y]/n) "
  read resp
  if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
    echo "$PROMPT $1 setup skipped."
    return 1
  else
    return 0
  fi
}

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
brew install gnuplot
brew install starship
brew tap cjbassi/ytop
brew install ytop
brew install httpie

brew install docker

if prompt_lang_install "Python" ; then
  brew install pyenv
  pyenv install-latest
  pip install pylint
  pip install pipenv
  echo "$PROMPT Python environment set up successfully."
fi

if prompt_lang_install "Rust" ; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup component add rustfmt
  rustup component add clippy
  echo "$PROMPT Rust environment set up successfully."
fi

if prompt_lang_install "Go" ; then
  brew install golang
  mkdir -p $HOME/go/{bin,src}
  echo "$PROMPT Go environment set up successfully."
fi

if prompt_lang_install "JavaScript" ; then
  brew install selenium-server-standalone
  # node.js
  brew install node
  npm install -g yarn
  yarn global add caniuse-cmd
  echo "$PROMPT JavaScript environment set up successfully."
fi

brew cleanup
