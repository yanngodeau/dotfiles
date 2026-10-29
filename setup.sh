#!/usr/bin/env bash
# Install (or remove) the dotfiles by symlinking every module into ~/.config
# with GNU Stow. Safe to re-run: existing links are refreshed, nothing is
# overwritten (stow aborts on conflicts and tells you which file is in the way).
#
# Usage:
#   ./setup.sh          install / refresh symlinks
#   ./setup.sh -n       dry run, only show what would change
#   ./setup.sh -D       remove the symlinks
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

dry_run=""
action="--restow"
while getopts "nDh" opt; do
  case "$opt" in
    n) dry_run="--no" ;;
    D) action="--delete" ;;
    *)
      sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

if ! command -v stow >/dev/null; then
  echo "GNU Stow is required: brew install stow | apt install stow | nix profile install nixpkgs#stow" >&2
  exit 1
fi

# macOS-only modules are skipped on other systems.
ignore_args=()
if [[ "$(uname -s)" != "Darwin" ]]; then
  ignore_args+=(--ignore='^/nix-darwin')
fi

mkdir -p "$HOME/.config"

info "Stowing modules into ~/.config ${dry_run:+(dry run)}"
# shellcheck disable=SC2086
stow $dry_run $action --verbose=1 "${ignore_args[@]}" .

[[ -n "$dry_run" || "$action" == "--delete" ]] && exit 0

# Zsh looks for ~/.zshrc, not ~/.config/zshrc/.zshrc.
zshrc_target="$HOME/.config/zshrc/.zshrc"
if [[ ! -e "$HOME/.zshrc" ]]; then
  ln -s "$zshrc_target" "$HOME/.zshrc"
  info "Linked ~/.zshrc -> $zshrc_target"
elif [[ "$(readlink "$HOME/.zshrc" || true)" != "$zshrc_target" ]]; then
  warn "~/.zshrc already exists and is not managed here; add 'source $zshrc_target' to it"
fi

for tool in nu starship zoxide atuin carapace direnv fzf eza bat nvim; do
  command -v "$tool" >/dev/null || missing+=("$tool")
done
if [[ -n "${missing:-}" ]]; then
  warn "not installed (configs reference them): ${missing[*]}"
fi

info "Done"
