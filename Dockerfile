FROM archlinux:base
RUN pacman -Syu --noconfirm sudo which reflector
RUN reflector --latest 20 --sort rate > /etc/pacman.d/mirrorlist
RUN useradd -ms /bin/bash qkniep && mkdir /home/qkniep/dotfiles
RUN echo "qkniep ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
USER qkniep
WORKDIR /home/qkniep/dotfiles
COPY . .
RUN sudo chown -hR qkniep /home/qkniep/dotfiles
ENTRYPOINT [ "bash" ]
