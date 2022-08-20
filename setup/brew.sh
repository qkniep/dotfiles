#! /bin/bash

# ==== Utility Functions =======================================

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

sudo -v

brew update
brew upgrade --all

brew install coreutils
brew install binutils

# ==== More Recent Versions of macOS Tools =====================

brew install gnu-sed --with-default-names
brew install wget --with-iri
brew install grep
brew install openssh
brew install gmp

# ==== Basic Development Tools =================================

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
brew install bat

# ==== Development Tool Casks ==================================

brew cask install --appdir="/Applications" atom
brew cask install --appdir="~/Applications" iterm2
brew cask install --appdir="~/Applications" java
brew cask install --appdir="/Applications" macdown
brew cask install --appdir="/Applications" virtualbox
brew cask install --appdir="/Applications" vagrant
brew cask install --appdir="~/Applications" xquartz

# ==== Miscellaneous Casks =====================================

brew cask install --appdir="/Applications" brave-browser
brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" signal
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" spark
brew cask install --appdir="/Applications" spotify
brew cask install --appdir="/Applications" whatsapp

brew install docker  # requires virtualbox

brew tap homebrew/cask-fonts
brew cask install font-hack-nerd-font
brew cask install font-fira-code-nerd-font

# ==== Language-Specific Development Tools =====================

if prompt_lang_install "Python" ; then
  brew install pyenv
  pyenv install-latest
  pip install pylint
  pip install pipenv

  if prompt_lang_install "Python Data Science Tools" ; then
    pip install numpy
    pip install scipy
    pip install matplotlib
    pip install pandas
    pip install sympy
    pip install nose
    pip install unittest2
    pip install seaborn
    pip install scikit-learn
    pip install "ipython[all]"
    pip install bokeh
    pip install Flask
    pip install sqlalchemy
    pip install mysqlclient
  fi
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
