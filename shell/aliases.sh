# shellcheck shell=bash
# Hermes general aliases and helper functions.

# Enhanced ls implementation depending on available tools.
if _hermes_has eza; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto'
  alias la='eza -a --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
elif _hermes_has exa; then
  alias ls='exa --group-directories-first --icons'
  alias ll='exa -lah --group-directories-first --icons'
  alias la='exa -a --group-directories-first --icons'
  alias lt='exa --tree --level=2 --group-directories-first --icons'
else
  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
  alias lt='ls -R --color=auto'
fi

# Prefer bat for rich file viewing when available.
if _hermes_has bat; then
  alias cat='bat --style=plain --paging=never'
elif _hermes_has batcat; then
  alias cat='batcat --style=plain --paging=never'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

alias please='sudo'
alias path='tr : "\n" <<<"$PATH"'

# Grep/ripgrep conveniences.
if _hermes_has rg; then
  alias grep='rg --smart-case'
  alias rgi='rg --smart-case --hidden --iglob "!.git"'
else
  alias grep='grep --color=auto'
fi

# Find files quickly.
if _hermes_has fd; then
  alias ff='fd --hidden --exclude .git'
elif _hermes_has fdfind; then
  alias ff='fdfind --hidden --exclude .git'
else
  alias ff='find . -iname'
fi

# Git quick entry.
alias g='git'

# Mkdir + cd helper.
mkcd() {
  if [ $# -eq 0 ]; then
    printf 'mkcd: missing directory name\n' >&2
    return 1
  fi
  mkdir -p "$1" && cd "$1" || return
}

# Jump to the project root (git aware) quickly.
cproj() {
  if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    cd "$git_root" || return
  else
    printf 'cproj: not inside a git repository\n' >&2
    return 1
  fi
}

# Print disk usage in a friendly way.
alias duh='du -sh ./*'
alias dus='du -sh'

# Extract archives seamlessly.
extract() {
  if [ $# -eq 0 ]; then
    printf 'extract: provide at least one archive file\n' >&2
    return 1
  fi
  for archive in "$@"; do
    if [ ! -f "$archive" ]; then
      printf 'extract: %s is not a file\n' "$archive" >&2
      continue
    fi
    case "$archive" in
      *.tar.bz2)   tar xjf "$archive" ;;
      *.tar.gz)    tar xzf "$archive" ;;
      *.tar.xz)    tar xJf "$archive" ;;
      *.tar)       tar xf "$archive" ;;
      *.tbz2)      tar xjf "$archive" ;;
      *.tgz)       tar xzf "$archive" ;;
      *.zip)       unzip "$archive" ;;
      *.rar)       unrar x "$archive" ;;
      *.7z)        7z x "$archive" ;;
      *.gz)        gunzip "$archive" ;;
      *.bz2)       bunzip2 "$archive" ;;
      *)
        printf 'extract: cannot extract %s\n' "$archive" >&2
        ;;
    esac
  done
}

# Improved pushd/popd wrappers with shorter names.
alias pu='pushd'
alias po='popd'

# Display a clean process view when procs is available.
if _hermes_has procs; then
  alias ps='procs'
fi

# Fast directory navigator backed by hermes-nn.
nn() {
  local mode="cd"
  local editor="${VISUAL:-${EDITOR:-nano}}"

  while [ $# -gt 0 ]; do
    case "$1" in
      --list|--help)
        hermes-nn "$@"
        return
        ;;
      --path)
        mode="print"
        shift
        break
        ;;
      --edit)
        mkdir -p "$HERMES_CONFIG_HOME"
        "$editor" "$HERMES_CONFIG_HOME/navmap.json"
        return
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
  done

  if [ $# -eq 0 ]; then
    hermes-nn --help
    return 1
  fi

  local destination
  if ! destination="$(hermes-nn "$@")"; then
    return $?
  fi

  if [ -z "$destination" ]; then
    return 1
  fi

  if [ "$mode" = "print" ]; then
    printf '%s\n' "$destination"
  else
    builtin cd "$destination" || return
  fi
}
