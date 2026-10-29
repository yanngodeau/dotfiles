# Nushell environment config
# version = "0.110.0"
#
# Nushell loads its own defaults first (default_env.nu), so only overrides
# and machine setup live here. config.nu is loaded after this file.

# ============================================================================
# PATH (skipped inside devbox shells, which manage their own PATH)
# ============================================================================
if 'DEVBOX_SHELL_ENABLED' not-in $env {
    let extra_paths = [
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        "/opt/homebrew/opt/ruby/bin"
        ($nu.home-dir | path join ".local" "bin")
        ($nu.home-dir | path join "go" "bin")
        ($nu.home-dir | path join ".cargo" "bin")
        ($nu.home-dir | path join ".opencode" "bin")
    ]
    $env.PATH = ($env.PATH | append ($extra_paths | where { $in | path exists }) | uniq)
}

# ============================================================================
# Environment variables
# ============================================================================
let config_dir = ($env.XDG_CONFIG_HOME? | default ($nu.home-dir | path join ".config"))

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.STARSHIP_CONFIG = ($config_dir | path join "starship" "starship.toml")
$env.GOPATH = ($nu.home-dir | path join "go")
$env.DIRENV_LOG_FORMAT = ""

# Ruby gems installed with `gem install --user-install`
let gem_home = ($nu.home-dir | path join ".gem" "ruby" "3.4.0")
if ($gem_home | path exists) {
    $env.GEM_HOME = $gem_home
    $env.GEM_PATH = $gem_home
    $env.PATH = ($env.PATH | prepend ($gem_home | path join "bin"))
}

# ============================================================================
# Tool init scripts
# ============================================================================
# `source` is resolved at parse time, so config.nu can only source files that
# already exist. Generate them here, as empty files when a tool is missing,
# so config.nu never fails to parse.
mkdir ~/.cache/nushell

def init-script [tool: string, file: string, generate: closure] {
    let script = if (which $tool | is-not-empty) { do $generate } else { "" }
    $script | save -f ($nu.home-dir | path join ".cache" "nushell" $file)
}

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

init-script starship "starship.nu" { starship init nu }
init-script zoxide   "zoxide.nu"   { zoxide init nushell }
init-script carapace "carapace.nu" { carapace _carapace nushell }
init-script atuin    "atuin.nu"    { atuin init nu }
