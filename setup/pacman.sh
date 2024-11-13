#! /bin/bash

# Load utility functions and variables.
source ../utility.sh

# Exit on error.
set -e


# ==== Start Setup =============================================

pinfo "Updating system..."
pcmn -Syyu

# Build Tools
pinfo "Installing basic dependencies..."
pcmn -S base-devel \
  binutils \
  cmake \
  python \
  openssl \
  openssh \
  git \
  fish \
  curl \
  wget \
  tar \
  zip \
  unzip

pinfo "Installing the paru AUR manager..."
# This requires Rust.
pcmn -S rustup
rustup default stable
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru


# ==== GUI =====================================================

# Desktop Environment
pinfo "Installing desktop environment (wayland, sway, etc.)..."
pcmn -S wayland \
  xorg-wayland \
  sway \
  swaylock \
  swaybg \
  wl-clipboard \
  i3status-rust \
  greetd \
  alacritty \
  bemenu \
  fuzzel \
  dunst \
  imv \
  mpv \
  wallutils \
  grim \
  slurp \
  gammastep \
  nemo \
  papirus-icon-theme \
  ttf-nerd-fonts-symbols
paru -S azote \
  greetd-tuigreet \
  breeze-obsidian-cursor-theme \
  nerd-fonts-noto \
  nerd-fonts-hack \
  nerd-fonts-fira-code

# Applications
pinfo "Installing GUI applications..."
pcmn -S firefox \
  signal-desktop \
  bitwarden \
  thunderbird \
  okular \
  obsidian \
  gimp \
  spotifyd
paru -S zoom \
  brave-bin \
  remarkable \
  spotify \
  spotify-tui \
  slack-desktop \
  teams

# Sound
pinfo "Installing sound tools..."
pcmn -S alsa-tools \
  libvorbis \
  opus \
  flac \
  wavpack
paru -S alac-git


# ==== General Dev Tools =======================================

pinfo "Installing development tools..."
pcmn -S sqlite \
  redis \
  mariadb \
  postgresql \
  hyperfine

# Neovim
pinfo "Installing and setting up Neovim & packer.nvim..."
pcmn -S neovim \
  lua-language-server
paru -S nvim-packer-git
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'packadd packer.nvim' -c 'PackerSync'
echo ""

# CLI Tools
# Mostly Rust alternatives for the defaults.
pinfo "Installing CLI utilities..."
pcmn -S imagemagick \
  libwebp \
  libheif \
  gnuplot \
  httpie \
  fzf \
  nushell \
  starship \
  tokei \
  dua-cli \
  bat \
  exa \
  ripgrep \
  bottom \
  fd \
  zoxide
paru -S speed-test

# Docker
pinfo "Installing Docker..."
pcmn -S docker docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
paru -S dockerfile-language-server


# ==== Language-Specific Dev Tools =============================

if prompt_lang_install "Rust" ; then
  # We already installed the Rust compiler to build paru.
  pcmn -S rust-analyzer
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
      python-flask \
      python-networkx
    paru -S python-nxviz \
      python-plotly
  fi
  psuccess "$PROMPT Python environment set up successfully."
fi

if prompt_lang_install "Go" ; then
  pcmn -S go \
    go-tools \
    gopls \
    goreleaser \
    sqlc
  paru -S go-task-bin \
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
  paru -S nvm
  yarn global add caniuse-cmd
  psuccess "$PROMPT JS/TS environment set up successfully."
fi

if prompt_lang_install "Java" ; then
  pcmn -S jdk-openjdk
  paru -S java-language-server
  psuccess "$PROMPT Java environment set up successfully."
fi

if prompt_lang_install "Haskell" ; then
  pcmn -S ghc \
    cabal-install \
    haskell-language-server
  psuccess "$PROMPT Haskell environment set up successfully."
fi

if prompt_lang_install "LaTeX" ; then
  paru -S texlive-full
  pcmn -S texlab
  psuccess "$PROMPT LaTeX environment set up successfully."
fi
