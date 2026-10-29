# Dotfiles

Cross-platform dotfiles (macOS & Linux) managed with [GNU Stow](https://www.gnu.org/software/stow/). Each directory is a module that gets symlinked into `~/.config`.

## Installation

```bash
git clone https://github.com/yanngodeau/dotfiles ~/dotfiles
cd ~/dotfiles
./setup.sh
```

One command sets the machine up. The script:

1. installs the tools: Homebrew (installed if missing) and the `Brewfile` on macOS, `apt` plus the official starship/atuin installers on Debian/Ubuntu;
2. symlinks every module into `~/.config` with Stow (re-runnable, never overwrites existing files);
3. links `~/.zshrc` to the stowed zsh config;
4. offers to set nushell as the default shell;
5. lists anything the configs reference that is still not installed.

Options: `-c` configs only (no package installation), `-n` dry run of the stow step, `-D` remove the symlinks.

## What's included

| Module | Description |
|--------|-------------|
| `nushell` | Nushell — default shell. Only overrides on top of the built-in defaults: vi mode, aliases (git, k8s), direnv hook, starship/zoxide/carapace/atuin integration |
| `zshrc` | Zsh — fallback shell, same aliases, FZF, zoxide, atuin, direnv. Every integration is guarded, so it loads fine with tools missing |
| `starship` | Starship prompt — Catppuccin Mocha palette, AWS context |
| `atuin` | Shell history sync and search |
| `ghostty` | Ghostty terminal — Catppuccin Mocha, 70% opacity, blur, four Catppuccin theme variants |
| `nvim` | Neovim with [LazyVim](https://lazyvim.github.io/) — Go, Docker, Helm, Terraform, TypeScript extras, yamlfmt, codesnap |

## Key details

- **Theme**: Catppuccin Mocha across Ghostty, Starship
- **Font**: JetBrains Mono
- **Shell**: Nushell (default), Zsh (fallback)
- **Editor**: Neovim via `v` alias
- **Navigation**: `cx` (cd + list), `fcd` (fuzzy cd), `fv` (fuzzy vim), `rr` (ranger, zsh only)
