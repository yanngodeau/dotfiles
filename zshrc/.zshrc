# Zsh config — fallback shell (nushell is the default), kept lean.

# ============================================================================
# Environment
# ============================================================================
export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export GOPATH="$HOME/go"
export KUBECONFIG="$HOME/.kube/config"

# PATH: homebrew and user bins take precedence over system dirs
typeset -U path
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME/.local/bin"
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
  $path
)

# ============================================================================
# Completion
# ============================================================================
autoload -Uz compinit bashcompinit
compinit
bashcompinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
command -v kubectl &>/dev/null && source <(kubectl completion zsh)
command -v aws_completer &>/dev/null && complete -C "$(command -v aws_completer)" aws

# ============================================================================
# Plugins & key bindings
# ============================================================================
for f in \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [ -f "$f" ]; then
    source "$f"
    bindkey '^w' autosuggest-execute
    bindkey '^e' autosuggest-accept
    bindkey '^u' autosuggest-toggle
    break
  fi
done
unset f

bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

# ============================================================================
# Aliases
# ============================================================================
command -v bat  &>/dev/null && alias cat=bat
command -v tree &>/dev/null && alias la=tree
command -v xh   &>/dev/null && alias http=xh
alias v=nvim
alias cl=clear
alias nm="nmap -sC -sV -oN nmap"

# eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2 --icons --git"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Git
alias gst="git status"
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gco="git checkout"
alias gcoall="git checkout -- ."
alias gb="git branch"
alias gba="git branch -a"
alias gadd="git add"
alias ga="git add -p"
alias gdiff="git diff"
alias gr="git remote"
alias gre="git reset"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Kubernetes
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kc="kubectx"
alias kns="kubens"
alias kcns="kubectl config set-context --current --namespace"

# ============================================================================
# Functions
# ============================================================================
# Clipboard: pbcopy on macOS, wl-copy / xclip on Linux
if command -v pbcopy &>/dev/null; then
  CLIPBOARD_CMD="pbcopy"
elif command -v wl-copy &>/dev/null; then
  CLIPBOARD_CMD="wl-copy"
elif command -v xclip &>/dev/null; then
  CLIPBOARD_CMD="xclip -selection clipboard"
fi

cx()  { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f()   { find . -type f -not -path '*/.*' | fzf | ${=CLIPBOARD_CMD:-cat}; }
fv()  { nvim "$(find . -type f -not -path '*/.*' | fzf)"; }

# ranger: cd into the last visited directory on quit (Q)
ranger() {
  local IFS=$'\t\n'
  local tempfile
  tempfile="$(mktemp -t tmp.XXXXXX)"
  command ranger --cmd="map Q chain shell echo %d > \"$tempfile\"; quitall" "$@"
  if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$PWD" ]]; then
    cd -- "$(cat "$tempfile")" || return
  fi
  command rm -f -- "$tempfile" 2>/dev/null
}
alias rr=ranger

# ============================================================================
# Tool integrations
# ============================================================================
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
if command -v fzf &>/dev/null; then
  source <(fzf --zsh) 2>/dev/null || { [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh; }
fi
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide   &>/dev/null && eval "$(zoxide init zsh)"
command -v atuin    &>/dev/null && eval "$(atuin init zsh)"
command -v direnv   &>/dev/null && eval "$(direnv hook zsh)"
