# shellcheck shell=bash
# Git-centric aliases and helpers.

alias gs='git status -sb'
alias gst='git status -sb'
alias ga='git add'
alias gap='git add -p'
alias gb='git branch -a'
alias gco='git checkout'
alias gsw='git switch'
alias gswc='git switch -c'
alias gpl='git pull --ff-only'
alias gps='git push'
alias gpf='git push --force-with-lease'
alias gd='git diff'
alias gdc='git diff --cached'
alias gds='git diff --stat'
alias gl='git log --oneline --decorate --graph'
alias gll='git log --stat'
alias gblame='git blame'
alias gtag='git tag'
alias gwt='git worktree'

# Undo the last commit but keep changes staged.
gundo() {
  git reset --soft HEAD~1
}

# Sync the current branch with the chosen remote.
gsync() {
  local remote="${1:-origin}"
  git fetch "$remote" --prune && git pull --ff-only "$remote"
}

# Clean working tree aggressively (with confirmation).
gclean() {
  local answer
  read -r -p "This will remove ALL untracked files. Continue? [y/N] " answer
  case "$answer" in
    [Yy]*)
      git clean -fdx
      ;;
    *)
      printf 'Aborted.\n'
      ;;
  esac
}

# Shortcut to Hermes' fresh switch command.
alias gfs='git fresh-switch'
