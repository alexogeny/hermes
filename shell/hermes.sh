#!/usr/bin/env bash
# Hermes bootstrap script. Source this from your shell profile.

if [ -n "${HERMES_BOOTSTRAPPED:-}" ]; then
  return 0
fi
export HERMES_BOOTSTRAPPED=1

# Determine repository root.
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  _hermes_source="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
  _hermes_source="${(%):-%N}"
else
  _hermes_source="$0"
fi

# shellcheck disable=SC2169 # zsh compatibility
HERMES_ROOT="$(cd "$(dirname "$_hermes_source")/.." && pwd -P)"
unset _hermes_source
export HERMES_ROOT

# Configuration directory defaults to ~/.config/hermes.
if [ -z "${HERMES_CONFIG_HOME:-}" ]; then
  HERMES_CONFIG_HOME="$HOME/.config/hermes"
fi
export HERMES_CONFIG_HOME

# Add Hermes bin directory to the path if not already there.
_hermes_prepend_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

HERMES_BIN="$HERMES_ROOT/bin"
_hermes_prepend_path "$HERMES_BIN"
export PATH HERMES_BIN

# Helper for command existence checks.
_hermes_has() {
  command -v "$1" >/dev/null 2>&1
}

# Generic environment tweaks.
if _hermes_has rg; then
  export RIPGREP_CONFIG_PATH="${RIPGREP_CONFIG_PATH:-$HERMES_CONFIG_HOME/ripgrep.rc}"
fi

if _hermes_has fdfind; then
  export FZF_DEFAULT_COMMAND="fdfind --type f"
elif _hermes_has fd; then
  export FZF_DEFAULT_COMMAND="fd --type f"
fi

# shellcheck source=./aliases.sh
. "$HERMES_ROOT/shell/aliases.sh"

# shellcheck source=./git-aliases.sh
. "$HERMES_ROOT/shell/git-aliases.sh"
