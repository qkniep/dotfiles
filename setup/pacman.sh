#! /bin/bash

# ==== Utility Functions =======================================

RED='\u001b[31m'
GRN='\u001b[32m'
YEL='\u001b[33m'
BLU='\u001b[34m'
RST='\u001b[0m'

pinfo () {
  echo -e "$BLU$1$RST"
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

prompt_lang_install () {
  pinfo "$PROMPT Do you want to set up $1? [Y/n] "
  read resp
  if [ "$resp" = 'n' -o "$resp" = 'N' ] ; then
    pwarn "$PROMPT $1 setup skipped."
    return 1
  else
    return 0
  fi
}

pcmn() {
  sudo pacman --color=always "$@"
}


# ==== Start Setup =============================================

pinfo "Updating system..."
pcmn -Syyu

pinfo "Installing basic dependencies..."
pcmn -S base-devel \
  binutils \
  python \
  openssl \
  openssh \
  yay \
  fish \
  curl \
  wget \
  tar \
  zip \
  unzip

# TODO: Maybe replace yay with paru?!


# ==== GUI =====================================================

# Desktop Environment
pinfo "Installing desktop environment (xorg, i3, etc.)..."
pcmn -S xorg \
  i3-gaps \
  i3status-rust \
  alacritty \
  dmenu \
  rofi \
  dunst \
  imv \
  scrot \
  redshift \
  papirus-icon-theme \
  ttf-nerd-fonts-symbols
yay -S betterlockscreen \
  azote \
  nerd-fonts-noto \
  nerd-fonts-hack \
  nerd-fonts-fira-code

# TODO: Maybe replace X11 with wayland and i3 with sway?!
# NOTE: Then also replace dmenu/rofi with bemenu and scrot with grim & slurp.

# Applications
pinfo "Installing GUI applications..."
pcmn -S firefox \
  brave-browser \
  signal-desktop \
  bitwarden \
  thunderbird \
  okular \
  gimp \
  spotifyd
yay -S zoom \
  spotify \
  spotify-tui \
  slack-desktop \
  teams


# ==== General Dev Tools =======================================

pinfo "Installing development tools..."
pcmn -S sqlite \
  redis \
  postgresql \
  cmake \
  git

# Neovim
pinfo "Installing and setting up Neovim & packer.nvim..."
pcmn -S neovim \
  lua-language-server
yay -S nvim-packer-git
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'packadd packer.nvim' -c 'PackerSync'
echo ""

# CLI Tools
# Mostly Rust alternatives for the defaults.
pinfo "Installing CLI utilities..."
pcmn -S imagemagick \
  libwebp \
  gnuplot \
  httpie \
  fzf \
  starship \
  tokei \
  dust \
  bat \
  exa \
  ripgrep \
  bottom \
  fd \
  zoxide
yay -S speed-test

# Docker
pinfo "Installing Docker..."
pcmn -S docker docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
yay -S dockerfile-language-server

# TODO: Add Kubernetes?


# ==== Language-Specific Dev Tools =============================

if prompt_lang_install "Rust" ; then
  pcmn -S rustup \
    rust-analyzer
  rustup default stable
  rustup toolchain install nightly
  rustup component add rust-src
  cargo install cargo-tarpaulin \
    cargo-update \
    cargo-udeps \
    cargo-outdated \
    cargo-bloat \
    cargo-watch \
    cargo-criterion \
    diesel_cli \
    sqlx-cli \
    flamegraph \
    cargo-audit
  psuccess "$PROMPT Rust environment set up successfully."
fi

if prompt_lang_install "Python" ; then
  pcmn -S python-pip \
    pyright \
    python-pylint \
    python-virtualenv \
    python-pipenv

  if prompt_lang_install "Python Data Science Tools" ; then
    pcmn -S python-numpy \
      python-scipy \
      python-matplotlib \
      python-pandas \
      python-seaborn \
      python-pytorch \
      python-scikit-learn \
      jupyterlab \
      python-sqlalchemy \
      python-mysqlclient \
      python-flask
    yay -S python-bokeh
  fi
  psuccess "$PROMPT Python environment set up successfully."
fi

if prompt_lang_install "Go" ; then
  pcmn -S go \
    go-tools \
    gopls \
    sqlc \
  yay -S go-task-bin \
    gosec \
    scc
  mkdir -p $HOME/go/{bin,src}
  go install honnef.co/go/tools/cmd/staticcheck@latest
  go install github.com/kisielk/errcheck@latest
  go install golang.org/x/lint/golint@latest
  go install github.com/go-critic/go-critic/cmd/gocritic@latest
  psuccess "$PROMPT Go environment set up successfully."
fi

if prompt_lang_install "JavaScript" ; then
  pcmn -S deno \
    nodejs \
    npm \
    yarn \
    typescript \
    gulp \
    prettier \
    eslint \
    stylelint
  yay -S nvm
  yarn global add caniuse-cmd
  psuccess "$PROMPT JS/TS environment set up successfully."
fi

if prompt_lang_install "Java" ; then
  pcmn -S jdk-openjdk
  yay -S java-language-server
  psuccess "$PROMPT Java environment set up successfully."
fi

if prompt_lang_install "Haskell" ; then
  pcmn -S ghc \
    cabal-install \
    haskell-language-server
  psuccess "$PROMPT Haskell environment set up successfully."
fi

if prompt_lang_install "LaTeX" ; then
  yay -S texlive-full
  pcmn -S texlab
  psuccess "$PROMPT LaTeX environment set up successfully."
fi
