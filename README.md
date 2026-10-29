# Dotfiles

Cross-platform dotfiles (macOS & Linux) managed with [GNU Stow](https://www.gnu.org/software/stow/). Each directory is a module that gets symlinked into `~/.config`.

## Installation

```bash
git clone https://github.com/yanngodeau/dotfiles ~/dotfiles
cd ~/dotfiles
./setup.sh
```

The script:

- symlinks every module into `~/.config` with Stow (re-runnable, never overwrites existing files);
- skips the macOS-only `nix-darwin` module on Linux;
- links `~/.zshrc` to the stowed zsh config;
- lists the tools the configs reference that are not installed yet.

`./setup.sh -n` is a dry run, `./setup.sh -D` removes the symlinks.

### Set nushell as default shell

**macOS** (via nix-darwin, requires `--impure` for dynamic username):

```bash
darwin-rebuild switch --flake ~/.config/nix-darwin#default --impure
```

**Linux**:

```bash
chsh -s $(which nu)
```

## What's included

| Module | Description |
|--------|-------------|
| `nushell` | Nushell — default shell. Only overrides on top of the built-in defaults: vi mode, aliases (git, k8s), direnv hook, starship/zoxide/carapace/atuin integration |
| `zshrc` | Zsh — fallback shell, same aliases, FZF, zoxide, atuin, direnv. Every integration is guarded, so it loads fine with tools missing |
| `starship` | Starship prompt — Catppuccin Mocha palette, AWS context |
| `atuin` | Shell history sync and search |
| `ghostty` | Ghostty terminal — Catppuccin Mocha, 70% opacity, blur, four Catppuccin theme variants |
| `nvim` | Neovim with [LazyVim](https://lazyvim.github.io/) — Go, Docker, Helm, Terraform, TypeScript extras, yamlfmt, codesnap |
| `nix` | Nix package manager configuration (flakes enabled) |
| `nix-darwin` | Nix Darwin system config (macOS only) — homebrew, dock, Finder preferences, TouchID sudo, home-manager, nushell as default shell |

## Key details

- **Theme**: Catppuccin Mocha across Ghostty, Starship
- **Font**: JetBrains Mono
- **Shell**: Nushell (default), Zsh (fallback)
- **Editor**: Neovim via `v` alias
- **Navigation**: `cx` (cd + list), `fcd` (fuzzy cd), `fv` (fuzzy vim), `rr` (ranger, zsh only)
