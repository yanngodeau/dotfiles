# home-manager configuration, wired in from flake.nix.
# Dotfiles themselves are managed with GNU Stow (see README), not home.file.
{ config, pkgs, ... }:

let
  username = builtins.getEnv "USER";
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # User-specific packages that should not be available system-wide
  home.packages = [ ];

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;
  # The real zsh config is ~/.config/zshrc/.zshrc (stowed); zsh here only
  # makes sure nix paths are available before it loads.
  programs.zsh = {
    enable = true;
    initExtra = ''
      source "$HOME/.config/zshrc/.zshrc"
    '';
  };
}
