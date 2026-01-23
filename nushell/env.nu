# Nushell Environment Config File
#
# version = "0.110.0"

def create_left_prompt [] {
    let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-dir }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"

# Conditional PATH additions (only outside nix/devbox shells)
if 'IN_NIX_SHELL' not-in $env and 'DEVBOX_SHELL_ENABLED' not-in $env {
    # Build paths dynamically
    let additional_paths = [
        "/opt/homebrew/bin"
        "/run/current-system/sw/bin"
        ($nu.home-dir | path join ".local" "bin")
        "/opt/homebrew/opt/ruby/bin"
        "/opt/homebrew/sbin"
        ($nu.home-dir | path join ".opencode" "bin")
    ]
    
    # Only add paths that exist
    $env.PATH = ($env.PATH | append ($additional_paths | where { $in | path exists }))
}

# ============================================================================
# Tool Initialization
# ============================================================================
# These tools generate init scripts that must exist before config.nu sources them.
# We create empty files as fallback if tools are not installed.

# Cache directories
let cache_dir = ($nu.home-dir | path join ".cache")
let starship_cache = ($cache_dir | path join "starship")
let carapace_cache = ($cache_dir | path join "carapace")

# Ensure cache directories exist
mkdir $starship_cache
mkdir $carapace_cache

# Init file paths
let zoxide_init = ($nu.home-dir | path join ".zoxide.nu")
let starship_init = ($starship_cache | path join "init.nu")
let carapace_init = ($carapace_cache | path join "init.nu")

# Starship
if (which starship | is-not-empty) {
    starship init nu | save -f $starship_init
} else {
    # Create empty file so source doesn't fail
    "" | save -f $starship_init
}

# Zoxide
if (which zoxide | is-not-empty) {
    zoxide init nushell | save -f $zoxide_init
} else {
    "" | save -f $zoxide_init
}

# Carapace
if (which carapace | is-not-empty) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace nushell | save -f $carapace_init
} else {
    "" | save -f $carapace_init
}

# ============================================================================
# Environment Variables (using dynamic paths)
# ============================================================================
let config_dir = ($nu.home-dir | path join ".config")

$env.STARSHIP_CONFIG = ($config_dir | path join "starship" "starship.toml")
$env.NIX_CONF_DIR = ($config_dir | path join "nix")
$env.EDITOR = "nvim"
