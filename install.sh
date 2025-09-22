#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Bootstrap Hermes into your environment.

Options:
      --prefix DIR         Configuration directory (default: ~/.config/hermes)
      --shell-profile FILE Append Hermes to the given shell profile (can repeat)
      --skip-shell         Skip modifying shell profiles
      --git                Include git/hermes.gitconfig into global git config
      --dry-run            Show actions without executing them
  -h, --help               Show this help message

Examples:
  ./install.sh --git                    # copy configs and enable git aliases
  ./install.sh --shell-profile ~/.zshrc # explicitly add to zshrc
USAGE
}

prefix="${HERMES_CONFIG_HOME:-$HOME/.config/hermes}"
declare -a shell_profiles=()
configure_git=0
skip_shell=0
dry_run=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      [[ $# -ge 2 ]] || { echo "--prefix requires a value" >&2; exit 1; }
      prefix="${2/#\~/$HOME}"
      shift 2
      ;;
    --shell-profile)
      [[ $# -ge 2 ]] || { echo "--shell-profile requires a value" >&2; exit 1; }
      shell_profiles+=("${2/#\~/$HOME}")
      shift 2
      ;;
    --skip-shell)
      skip_shell=1
      shift
      ;;
    --git)
      configure_git=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

script_dir="$(cd "$(dirname "$0")" && pwd -P)"
repo_root="$script_dir"

mkdir_cmd() {
  if [[ $dry_run -eq 1 ]]; then
    echo "mkdir -p $1"
  else
    mkdir -p "$1"
  fi
}

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    echo "keep    $dest"
  else
    if [[ $dry_run -eq 1 ]]; then
      echo "copy    $src -> $dest"
    else
      mkdir -p "$(dirname "$dest")"
      cp "$src" "$dest"
      echo "copied  $src -> $dest"
    fi
  fi
}

append_if_missing() {
  local file="$1"
  local line="$2"
  if [[ ! -f "$file" ]]; then
    if [[ $dry_run -eq 1 ]]; then
      echo "create  $file"
    else
      touch "$file"
      echo "created $file"
    fi
  fi

  if grep -F "$line" "$file" >/dev/null 2>&1; then
    echo "keep    $file (already configured)"
  else
    if [[ $dry_run -eq 1 ]]; then
      echo "append  $line -> $file"
    else
      printf '\n%s\n' "$line" >>"$file"
      echo "updated $file"
    fi
  fi
}

mkdir_cmd "$prefix"
copy_if_missing "$repo_root/config/navmap.sample.json" "$prefix/navmap.json"
copy_if_missing "$repo_root/config/ripgrep.rc" "$prefix/ripgrep.rc"

if [[ $skip_shell -eq 0 ]]; then
  if [[ ${#shell_profiles[@]} -eq 0 ]]; then
    if [[ -f "$HOME/.zshrc" ]]; then
      shell_profiles+=("$HOME/.zshrc")
    fi
    if [[ -f "$HOME/.bashrc" ]]; then
      shell_profiles+=("$HOME/.bashrc")
    fi
  fi

  if [[ ${#shell_profiles[@]} -eq 0 ]]; then
    echo "No shell profile detected. Use --shell-profile to specify one." >&2
  else
    for profile in "${shell_profiles[@]}"; do
      append_if_missing "$profile" "source $repo_root/shell/hermes.sh"
    done
  fi
fi

if [[ $configure_git -eq 1 ]]; then
  git_config_cmd=(git config --global include.path "$repo_root/git/hermes.gitconfig")
  if [[ $dry_run -eq 1 ]]; then
    echo "${git_config_cmd[*]}"
  else
    "${git_config_cmd[@]}"
  fi
fi

echo "Hermes bootstrap complete."
