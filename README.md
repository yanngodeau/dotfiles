# Dotfiles

Cross-platform dotfiles (macOS & Linux) managed with [GNU Stow](https://www.gnu.org/software/stow/). Each directory is a module that gets symlinked into `~/.config`.

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Nix](https://nixos.org/) (optional, for nix-darwin on macOS)

## Installation

```bash
stow .
```

This reads `.stowrc` which targets `~/.config`, so every module directory (e.g. `nvim/`) is symlinked to `~/.config/nvim/`.

### Set nushell as default shell

**macOS** (via nix-darwin):

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

**Linux**:

```bash
chsh -s $(which nu)
```

## What's included

### Shell

| Module | Description |
|--------|-------------|
| `nushell` | Nushell — default shell, aliases (git, docker, k8s), vi mode, carapace completions, zoxide, direnv, starship |
| `zshrc` | Zsh — fallback shell, aliases, FZF integration, zoxide, direnv |
| `starship` | Starship prompt — Catppuccin Mocha palette, AWS/Kubernetes context |
| `atuin` | Shell history sync and search |

### Terminal emulators

| Module | Description |
|--------|-------------|
| `ghostty` | Ghostty — Catppuccin Mocha, 70% opacity, blur, multiple theme variants |
| `wezterm` | WezTerm — Catppuccin Mocha, JetBrains Mono 16pt, custom keybinds |

### Terminal multiplexers

| Module | Description |
|--------|-------------|
| `tmux` | Tmux — prefix `Ctrl-A`, vi keybindings, Catppuccin theme, 15+ plugins (TPM, resurrect, continuum, sessionx, floax) |
| `zellij` | Zellij — custom keybindings, hjkl pane navigation |

### Editor

| Module | Description |
|--------|-------------|
| `nvim` | Neovim with [LazyVim](https://lazyvim.github.io/) — LSP, completion (blink.cmp), treesitter, fzf-lua, gitsigns, mini plugins, Go support |

### Window management & automation (macOS only)

| Module | Description |
|--------|-------------|
| `aerospace` | AeroSpace tiling window manager — 4 workspaces, auto-layout, floating rules per app |
| `sketchybar` | SketchyBar status bar — scripts for CPU, calendar, GitHub notifications, workspaces |
| `skhd` | Simple hotkey daemon — app launchers, custom shortcuts |
| `karabiner` | Karabiner-Elements keyboard remapping |
| `hammerspoon` | Hammerspoon automation — calendar, app launcher, custom hotkeys |
| `kindavim` | KindaVim — vi keybindings in native macOS text fields |

### System

| Module | Description |
|--------|-------------|
| `nix` | Nix package manager configuration (flakes enabled) |
| `nix-darwin` | Nix Darwin system config (macOS only) — homebrew, dock, Finder preferences, TouchID sudo, home-manager, nushell as default shell |
| `ssh` | SSH client configuration |

## Post-install

### Tmux plugins

Install TPM then press `prefix + I` inside tmux to fetch plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Hammerspoon (macOS only)

Point Hammerspoon to the stowed config:

```bash
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
```

## Key details

- **Theme**: Catppuccin Mocha across Ghostty, WezTerm, Tmux, Starship
- **Font**: JetBrains Mono
- **Shell**: Nushell (default), Zsh (fallback)
- **Editor**: Neovim via `v` alias
- **Navigation aliases**: `cx` (cd + list), `fcd` (fuzzy cd), `fv` (fuzzy vim), `rr` (ranger)
