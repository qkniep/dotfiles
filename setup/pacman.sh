#! /bin/sh

sudo pacman -Syu

sudo pacman -S base-devel
sudo pacman -S binutils
sudo pacman -S yay

# GUI
sudo pacman -S xorg
sudo pacman -S i3
sudo pacman -S alacritty
sudo pacman -S dunst

sudo yay -S betterlockscreen
sudo yay -S nerd-fonts-fira-code

# ==== Basic Development Tools =================================

sudo pacman -S curl
sudo pacman -S wget
sudo pacman -S git
#git-lfs
sudo pacman -S neovim
sudo yay -S ripgrep
sudo pacman -S imagemagick
sudo pacman -S libwebp
sudo pacman -S gnuplot
sudo pacman -S starship
sudo pacman -S ytop
sudo pacman -S httpie
sudo pacman -S bat

sudo pacman -S docker

# ==== Language-Specific Development Tools =====================

if prompt_lang_install "Python" ; then
  sudo pacman -S python
  pip install pylint
  pip install pipenv

  if prompt_lang_install "Python Data Science Tools" ; then
    pip install numpy
    pip install scipy
    pip install matplotlib
    pip install pandas
    #pip install sympy
    #pip install nose
    #pip install unittest2
    pip install seaborn
    pip install scikit-learn
    #pip install "ipython[all]"
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
  sudo pacman -S go
  sudo pacman -S go-tools
  mkdir -p $HOME/go/{bin,src}
  echo "$PROMPT Go environment set up successfully."
fi

if prompt_lang_install "JavaScript" ; then
  sudo yay -S selenium-server-standalone
  # node.js
  sudo pacman -S nodejs
  npm install -g yarn
  yarn global add caniuse-cmd
fi


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
