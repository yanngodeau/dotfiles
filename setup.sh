#!/usr/bin/env bash
# Set up a machine from these dotfiles: install the tools, then symlink the
# configs into ~/.config with GNU Stow. Safe to re-run.
#
# Usage:
#   ./setup.sh        install tools (Homebrew on macOS, apt on Debian/Ubuntu)
#                     and symlink the configs
#   ./setup.sh -c     configs only, skip package installation
#   ./setup.sh -n     dry run: show what stow would change
#   ./setup.sh -D     remove the symlinks
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_pkgs=1
dry_run=""
action="--restow"
while getopts "cnDh" opt; do
  case "$opt" in
    c) install_pkgs=0 ;;
    n) dry_run="--no"; install_pkgs=0 ;;
    D) action="--delete"; install_pkgs=0 ;;
    *)
      sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
os="$(uname -s)"

# ----------------------------------------------------------------------------
# 1. Packages
# ----------------------------------------------------------------------------
install_macos() {
  if ! command -v brew >/dev/null; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if ! command -v brew >/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
  info "Installing packages from Brewfile"
  brew bundle --file=Brewfile
}

install_linux() {
  if ! command -v apt-get >/dev/null; then
    warn "no apt-get: install the tools listed in Brewfile with your package manager"
    return
  fi
  info "Installing packages with apt"
  sudo apt-get update -qq
  # Installed one by one: some are missing on older distributions.
  for pkg in stow zsh git curl direnv fzf bat fd-find ripgrep neovim zoxide eza tree ranger; do
    sudo apt-get install -y -qq "$pkg" >/dev/null 2>&1 || warn "apt has no '$pkg', install it manually"
  done
  # Debian names the binaries batcat / fdfind; expose them under their usual names.
  mkdir -p "$HOME/.local/bin"
  command -v bat >/dev/null || ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" 2>/dev/null || true
  command -v fd  >/dev/null || ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true

  # Not packaged by apt: official installers (binaries go to ~/.local/bin or ~/.atuin/bin).
  if ! command -v starship >/dev/null; then
    info "Installing starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  fi
  if ! command -v atuin >/dev/null; then
    info "Installing atuin"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  fi
  command -v nu       >/dev/null || warn "nushell is not packaged by apt: https://www.nushell.sh/book/installation.html"
  command -v carapace >/dev/null || warn "carapace is not packaged by apt: https://carapace-sh.github.io/carapace-bin/install.html"
  command -v ghostty  >/dev/null || warn "ghostty: https://ghostty.org/docs/install/binary"
}

if [[ $install_pkgs -eq 1 ]]; then
  case "$os" in
    Darwin) install_macos ;;
    Linux)  install_linux ;;
    *)      warn "unsupported OS '$os', skipping package installation" ;;
  esac
fi

# ----------------------------------------------------------------------------
# 2. Configs
# ----------------------------------------------------------------------------
if ! command -v stow >/dev/null; then
  echo "GNU Stow is required: brew install stow | apt install stow" >&2
  exit 1
fi

mkdir -p "$HOME/.config"
info "Stowing modules into ~/.config ${dry_run:+(dry run)}"
# shellcheck disable=SC2086
stow $dry_run $action --verbose=1 .

[[ -n "$dry_run" || "$action" == "--delete" ]] && exit 0

# Zsh looks for ~/.zshrc, not ~/.config/zshrc/.zshrc.
zshrc_target="$HOME/.config/zshrc/.zshrc"
if [[ ! -e "$HOME/.zshrc" ]]; then
  ln -s "$zshrc_target" "$HOME/.zshrc"
  info "Linked ~/.zshrc -> $zshrc_target"
elif [[ "$(readlink "$HOME/.zshrc" || true)" != "$zshrc_target" ]]; then
  warn "~/.zshrc already exists and is not managed here; add 'source $zshrc_target' to it"
fi

# ----------------------------------------------------------------------------
# 3. Default shell
# ----------------------------------------------------------------------------
if nu_path="$(command -v nu 2>/dev/null)" && [[ "${SHELL:-}" != "$nu_path" ]] && [[ -t 0 ]]; then
  read -r -p "Set nushell ($nu_path) as your default shell? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    grep -qx "$nu_path" /etc/shells || echo "$nu_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$nu_path"
    info "Default shell set to nushell (takes effect in new sessions)"
  fi
fi

# ----------------------------------------------------------------------------
# 4. Report
# ----------------------------------------------------------------------------
missing=()
for tool in nu starship zoxide atuin carapace direnv fzf fd eza bat nvim; do
  command -v "$tool" >/dev/null || missing+=("$tool")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  warn "not installed (configs reference them): ${missing[*]}"
fi

info "Done"
