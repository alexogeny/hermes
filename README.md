# Hermes

Hermes turns a bare shell into a high-velocity Linux development cockpit. It
adds expressive navigation, sensible aliases, curated git automation and an
installation script that wires everything into your dotfiles in seconds.

## Highlights

- **Expressive shell ergonomics** – smart `ls`/`rg` wrappers, `mkcd`, archive
  extraction, fast process views, and opinionated quality-of-life aliases that
  behave gracefully even when optional utilities are missing.
- **Navigation that keeps up** – the `nn` function jumps through complex folder
  hierarchies using fuzzy tokens (`nn w/gl/ev/bf`) backed by a JSON map you can
  tweak to taste.
- **Git superpowers** – global aliases, a `fresh-switch` command that wipes all
  local state and recreates branches exactly from the remote, and shortcuts like
  `gcl` to clone repos with terse provider prefixes.
- **Config-aware bootstrap** – `install.sh` copies sample configs, wires Hermes
  into your shell profiles, and optionally injects the git config include – all
  while supporting dry runs and custom destinations.

## Quick start

```bash
# Clone this repository somewhere convenient
cd ~/workspaces
git clone https://github.com/you/hermes.git
cd hermes

# Bootstrap Hermes (dry-run first if you want to preview actions)
./install.sh --dry-run
./install.sh --git
```

The installer will:

1. Create (or reuse) `~/.config/hermes` and drop sample configuration files.
2. Append `source /path/to/hermes/shell/hermes.sh` to detected shell profiles
   (`~/.zshrc` and `~/.bashrc` by default) unless you pass `--skip-shell`.
3. Include `git/hermes.gitconfig` into your global git config when `--git` is
   supplied.

To customize the config directory or shell profile just pass
`--prefix`/`--shell-profile` arguments. Everything can be previewed with
`--dry-run`.

## Daily drivers

### Navigation (`nn`)

- `nn tokens...` – hop into directories described by successive tokens.
- `nn w/gl/ev/bf` – example: `w` (~/work) → `gl` (gitlab) → `ev` (evernet) →
  `bf` (betterfly).
- `nn --path w/gl/ev` – print the resolved path instead of changing directory.
- `nn --list` – list every registered shortcut with its full path.
- `nn --edit` – open `~/.config/hermes/navmap.json` in your `$EDITOR`.

Shortcuts live in a simple JSON tree (`config/navmap.sample.json`). Each node
contains aliases and a path segment:

```json
{
  "aliases": ["w", "work"],
  "segment": "~/work",
  "children": [
    { "aliases": ["gl", "gitlab"], "segment": "gitlab" }
  ]
}
```

Hermes matches tokens by prefix, so `nn w g e` would also navigate to the same
location as long as the prefix is unambiguous.

### Git workflow accelerators

- `git fresh-switch <branch> [remote] [base]` – hard reset your worktree, fetch
  from the remote, and recreate the branch exactly from the remote reference.
  Pass `--include-ignored` to nuke ignored files as well and `--push` to publish
  immediately.
- `gfs` – shell alias for `git fresh-switch`.
- `git scope key=value ...` – create directory-specific git config includes so
  every repo within a folder inherits the right identity. Try
  `gitconfig username=acme-dev useremail=dev@acme.com` from
  `~/work/gitlab/acme` to pin your name/email for that tree. Use `--list` to see
  all scoped configs and `--unset key` to remove entries.
- `gcl <namespace/repo>` – clone from GitHub/GitLab/Bitbucket using the terse
  providers (`gh:`, `gl:`, `bb:`) or custom hosts via `-H`. Use
  `gcl --protocol https ...` if you prefer HTTPS.
- Git aliases provided in `git/hermes.gitconfig` include goodies like `git lg`
  (graph view), `git recent` (15 latest branches by activity) and
  `git cleanup-merged`.

### Shell enhancements

- Smarter `ls`/`ll`/`lt` that automatically use `eza`/`exa` if installed.
- `ff` is backed by `fd`/`fdfind` (with a `find` fallback) for blazing file
  searches.
- `grep` automatically becomes ripgrep when available (configured via
  `~/.config/hermes/ripgrep.rc`).
- Helpers like `mkcd`, `cproj` (jump to current git root), archive `extract`,
  and `please` (`sudo`).

## Recommended tooling

Hermes detects and embraces faster replacements when they exist. Install the
following to unlock the best experience:

- [`eza`](https://github.com/eza-community/eza) or `exa` – modern directory
  listings.
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) – blazing fast searching.
- [`fd`](https://github.com/sharkdp/fd)`/`fdfind` – project-aware file finding.
- [`bat`](https://github.com/sharkdp/bat)`/`batcat` – syntax-highlighted pager.
- [`procs`](https://github.com/dalance/procs)`/`bottom` – richer process views.

The environment variables exposed by `shell/hermes.sh` make it easy to adapt
Hermes further:

- `HERMES_CONFIG_HOME` – alternate configuration directory.
- `HERMES_NAVMAP` – point directly at a navigation map file.
- `HERMES_GCL_*` – tune cloning defaults (`HERMES_GCL_PROTOCOL`,
  `HERMES_GCL_DEFAULT_PROVIDER`, host overrides, and extra clone flags).

## Updating

Hermes is purely shell/Python – pull the latest changes and re-run the installer
if new configuration is introduced. Existing configs are left untouched so your
customizations stay intact.
