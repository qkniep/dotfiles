#!/bin/bash

cd ~/.config/nix-darwin
nix flake update
sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#qk-macbook
