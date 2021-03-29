#! /bin/sh

echo "Updating system..."
sudo pacman -Syu

echo "Installing basic dependencies..."
sudo pacman -S base-devel
sudo pacman -S binutils
sudo pacman -S python
sudo pacman -S yay


# ==== GUI =====================================================

echo "Installing GUI applications..."

sudo pacman -S xorg
sudo pacman -S i3
sudo pacman -S alacritty
sudo pacman -S dunst

yay -S betterlockscreen
yay -S nerd-fonts-fira-code
yay -S nerd-fonts-hack

sudo pacman -S firefox
sudo pacman -S brave
sudo pacman -S whatsapp-web
sudo pacman -S signal-desktop
yay -S zoom

sudo pacman -S snapd
sudo systemctl enable --now snapd.socket
sudo snap install spotify
sudo snap install slack


# ==== Basic Development Tools =================================

echo "Installing development tools and CLI utilities..."

sudo pacman -S zip
sudo pacman -S unzip

sudo pacman -S postgresql
sudo pacman -S jdk-openjdk
sudo pacman -S cmake
sudo pacman -S curl
sudo pacman -S wget
sudo pacman -S git
yay -S git-lfs

sudo pacman -S neovim
sudo pacman -S python-pynvim # needed for denite plugin

sudo pacman -S imagemagick   # Image editing tools
sudo pacman -S libwebp       # WebP image format conversion
sudo pacman -S gnuplot       # CLI plotting utility
sudo pacman -S httpie        # CLI HTTP request (like curl)
sudo pacman -S starship      # Rust command prompt
sudo pacman -S exa           # Rust alternative for ls
sudo pacman -S bat           # Rust alternative for cat
sudo pacman -S fd            # Rust alternative for find
yay -S dust                  # Rust alternative for du
yay -S ripgrep               # Rust alternative for grep
yay -S bottom-bin            # Rust alternative for top

sudo pacman -S docker
sudo pacman -S docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker.service


# ==== Language-Specific Development Tools =====================

if prompt_lang_install "Python" ; then
  pip install pylint
  pip install pipenv

  if prompt_lang_install "Python Data Science Tools" ; then
    pip install numpy
    pip install scipy
    pip install matplotlib
    pip install pandas
    pip install seaborn
    pip install scikit-learn
    pip install jupyterlab
    pip install bokeh
    pip install Flask
    pip install sqlalchemy
    pip install mysqlclient
  fi
  echo "$PROMPT Python environment set up successfully."
fi

if prompt_lang_install "Rust" ; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup component add rls rust-analysis rust-src
  echo "$PROMPT Rust environment set up successfully."
fi

if prompt_lang_install "Go" ; then
  sudo pacman -S go
  sudo pacman -S go-tools
  mkdir -p $HOME/go/{bin,src}
  go get -u golang.org/x/tools/gopls
  go get -u github.com/go-task/task/v3/cmd/task
  go get -u github.com/kyleconroy/sqlc/cmd/sqlc
  go get -u github.com/securego/gosec/v2/cmd/gosec
  go get -u honnef.co/go/tools/cmd/staticcheck
  go get -u github.com/kisielk/errcheck
  go get -u golang.org/x/lint/golint
  go get -u github.com/go-critic/go-critic/cmd/gocritic
  go get -u github.com/boyter/scc
  echo "$PROMPT Go environment set up successfully."
fi

if prompt_lang_install "JavaScript" ; then
  yay -S selenium-server-standalone
  sudo pacman -S nodejs
  npm install -g yarn
  yarn global add caniuse-cmd
  yarn global add gulp
  yarn global add eslint
  yarn global add stylelint
fi

if prompt_lang_install "Haskell" ; then
  sudo pacman -S ghc
  sudo pacman -S cabal-install
fi


# ==== Utility Functions =======================================

prompt_lang_install () {
  printf "$PROMPT Do you want to set up $1? [Y/n] "
  read resp
  if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
    echo "$PROMPT $1 setup skipped."
    return 1
  else
    return 0
  fi
}
