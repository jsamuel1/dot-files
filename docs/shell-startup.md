# Shell startup: which files load, when, and why

This repo configures zsh (the main shell), bash, and POSIX `sh`
(dash, and BusyBox `ash` on Alpine Linux). Each shell reads different files
depending on whether it is a login shell and whether it is interactive. This
page maps every case to the files that load, explains what each file is for,
and shows how to add workplace or box specific settings without editing the
core files.

## Files and what they do

All `dots/<name>` files are linked to `~/.<name>`, and `local/**` is linked to
`~/.local/**`, by `settings.py` (run from `bootstrap.sh`).

| File (in `~`) | Repo source | Shell | When | Purpose |
|---|---|---|---|---|
| `.zshenv` | `dots/zshenv` | zsh | every shell | Core `PATH` (Homebrew `bin`/`sbin`, cargo, mise shims, pnpm, ...) and the path helpers. Ends by loading `~/.shellenv`. Keep it fast: it runs for every script. |
| `.zprofile` | `dots/zprofile` | zsh | login | Re-sources `.zshenv`, because macOS `/etc/zprofile` runs `path_helper` and reorders `PATH`. |
| `.zshrc` | `dots/zshrc` | zsh | interactive | Prompt, history, key bindings, completions, aliases. Exits early when stdin and stdout aren't terminals (env-probe shells from IDEs and agents). Loads `~/.local/lib/*.zsh` near the top and `~/.local/lib/*.zsh-last` at the very end. |
| `.zshrc-helpers`, `.zshrc-optimize` | `dots/` | zsh | interactive | Helper functions and startup caching, sourced by `.zshrc`. |
| `.shellenv` | `dots/shellenv` | zsh, bash, sh/dash/ash | all except `bash -c` and `sh -c` | Shared POSIX `sh` environment. Defines `prepend_path`/`append_path` if the shell doesn't already have them, then loads `~/.local/lib/*.env.sh`. |
| `.bashrc` | `dots/bashrc` | bash | interactive, and `ssh host cmd` | Loads `~/.shellenv` first, then exits if non-interactive; otherwise prompt, aliases, completion. |
| `.bash_profile` | machine-local, not in repo | bash | login | Installers append to it. It should end with `[ -r "$HOME/.shellenv" ] && . "$HOME/.shellenv"`. |
| `.profile` | `dots/profile` | sh/dash/ash; bash when there is no `.bash_profile` | login | POSIX only. Loads `~/.shellenv` and exports `ENV=~/.shellenv` so interactive non-login `sh` shells get it too. |
| `.local/lib/*.zsh` | `local/lib/` here and in other repos | zsh | interactive | Aliases, functions, interactive env (`aliases.zsh`, `defaultenv.zsh`, `kmux.zsh`, ...). |
| `.local/lib/*.zsh-last` | other repos | zsh | interactive, at the end | For scripts that start a foreground program (e.g. `kmux.zsh-last`). |
| `.local/lib/*.env.sh` | `local/lib/` here and in other repos | zsh, bash, sh/dash/ash | all except `bash -c` and `sh -c` | Workplace or box specific `PATH` and env vars (e.g. `toolbox.env.sh`, `aim.env.sh`). POSIX `sh` only. |

## Which files load for each shell type

"Login" means started with `-l`, or as a terminal's or SSH session's first
shell. "Interactive" means it reads commands from a terminal.

| Shell | Login | Interactive | Files loaded, in order | Gets `~/.shellenv`? |
|---|---|---|---|---|
| zsh | yes | yes | `/etc/zshenv`, `.zshenv`, `/etc/zprofile`, `.zprofile`, `.zshrc` (+ `*.zsh`, `*.zsh-last`) | yes |
| zsh | no | yes | `.zshenv`, `.zshrc` | yes |
| zsh | yes | no | `.zshenv`, `.zprofile` | yes |
| zsh | no | no (`zsh -c`, scripts) | `.zshenv` | yes |
| bash | yes | either | `/etc/profile`, then the first of `.bash_profile`, `.bash_login`, `.profile` | yes, via `.bash_profile` |
| bash | no | yes | `.bashrc` | yes |
| bash | no | no (`bash -c`, scripts) | only `$BASH_ENV` if set; `.bashrc` when started by `sshd` (`ssh host cmd`) | only with `BASH_ENV=~/.bashrc` or over SSH |
| sh / dash / ash | yes | either | `/etc/profile`, `.profile` | yes |
| sh / dash / ash | no | yes | `$ENV` (set to `~/.shellenv` by `.profile`) | yes |
| sh / dash / ash | no | no | nothing | no |

On Alpine, the default shell is BusyBox `ash`, so a login session reads
`/etc/profile` and then `~/.profile`. Everything `~/.profile` and
`~/.shellenv` load is POSIX `sh` so that it works there.

Plain non-interactive bash and `sh` shells read no startup files at all. That
is how those shells are designed. Programs that need the full `PATH` should
run under `zsh -c`, a login shell, or inherit `PATH` from a parent shell.

## One file per tool

Settings for a tool live in files named after that tool, one file per load
time. The extension decides when the file loads:

| File name | Loaded by | Use for | Syntax |
|---|---|---|---|
| `<tool>.env.sh` | `~/.shellenv`, so all shells except `bash -c` and `sh -c` | `PATH` and environment variables that scripts and agents also need | POSIX `sh` |
| `<tool>.zsh` | `.zshrc`, near the top | aliases, functions, completions, interactive-only env | zsh |
| `<tool>.zsh-last` | `.zshrc`, at the very end | hooks that must run last, e.g. ones that start a foreground program | zsh |

A tool can have any combination of these. For example, kiro-cmux has
`kmux.zsh` (wrappers and aliases) and `kmux.zsh-last` (the remote-panes hook),
and the Builder Toolbox has only `toolbox.env.sh`.

`*.env.sh` files load after the core `PATH`, so `prepend_path` in them puts
their directories first. Both helpers skip directories that don't exist, so
the same file is safe on machines without that tool. Re-sourcing moves
entries instead of duplicating them.

### macOS-only and Linux-only settings

There are no separate per-OS files. Most tool files don't need an OS check:

- `prepend_path`/`append_path` skip folders that don't exist, so a macOS
  path such as `$HOME/Library/pnpm` does nothing on Linux, and the reverse.
- Aliases and hooks are guarded on the command or file existing (see
  `kmux.zsh`), so they're skipped wherever the tool isn't installed.

Add an OS check inside the tool's file only for settings that aren't paths
and differ by OS, such as `PNPM_HOME` or the macOS-only
`AWS_EC2_METADATA_DISABLED`:

```sh
# <tool>.env.sh: POSIX sh doesn't guarantee $OSTYPE (dash doesn't set it)
case "$(uname -s)" in
  Darwin) export ACME_HOME="$HOME/Library/Acme" ;;
  *)      export ACME_HOME="$HOME/.local/share/acme" ;;
esac
```

```zsh
# <tool>.zsh: zsh sets $OSTYPE, which avoids running uname
[[ "$OSTYPE" == darwin* ]] && alias acme-open='open -a Acme'
```

## Everywhere vs workplace / box specific

Where a tool's files live depends on which machines need them:

| Scope | Repo location | How it reaches `~/.local/lib` |
|---|---|---|
| Every machine (pnpm, cargo, bun, ...) | `dot-files/local/lib/` | `settings.py` links `local/**` automatically |
| Workplace (Builder Toolbox, AIM, kiro-cmux, ...) | `dot-files-amazon/local/lib/` | `dot-files-amazon/symlink.sh` |
| One box only | a real file in `~/.local/lib/`, not in any repo | already there |

Current files:

| File | Repo |
|---|---|
| `toolbox.env.sh`, `aim.env.sh`, `smithy-mcp.env.sh`, `kmux.zsh`, `kmux.zsh-last`, `kiroenv.zsh`, `agienv.zsh`, `awsaliases.zsh`, `isengardcli.zsh`, `env_mappings.zsh` | `dot-files-amazon` |
| `aliases.zsh`, `completions.zsh`, `defaultenv.zsh`, `vscode.zsh` | `dot-files` |

## Adding settings for a tool

You don't need to edit any core file.

1. Pick the repo from the scope table, then add files under its `local/lib/`:

   ```sh
   # local/lib/acme.env.sh  (POSIX sh, all shells)
   prepend_path "$HOME/.acme/bin"
   export ACME_HOME="$HOME/.acme"
   ```

   ```zsh
   # local/lib/acme.zsh  (interactive zsh)
   alias deploy='acme deploy --confirm'
   ```

2. Link them into `~/.local/lib`: run `./settings.py --no-dryrun` in
   `dot-files`, or `./symlink.sh` in `dot-files-amazon`. For a single file:

   ```sh
   ln -s "$PWD/local/lib/acme.env.sh" ~/.local/lib/acme.env.sh
   ```

3. Open a new shell. Check with `zsh -c 'echo $PATH'` and `sh -lc 'echo $PATH'`.

Rules for `*.env.sh` files:

- POSIX `sh` only: no `[[ ]]`, arrays, `local`, `source`, or `${var//x/y}`.
  `sh -n file` and `shellcheck -s sh file` check this.
- Only set `PATH` and environment variables. They run for every script, so no
  output, prompts, aliases, or slow commands.
- Use `prepend_path`/`append_path`, not `export PATH=...:$PATH`, so missing
  directories are skipped and entries aren't duplicated.

## When installers edit your startup files

Installers (AIM, Kiro CLI, kiro-cmux, smithy-mcp, LM Studio, rustup, ...)
append blocks to `~/.zshrc`, `~/.bashrc`, `~/.profile`, or `~/.bash_profile`,
usually marked `# Added by <tool>`. The first three are symlinks into this
repo, so the blocks show up in `git status`. `~/.bash_profile` is
machine-local, so check it by hand.

Move each block into that tool's files instead of keeping it in the core file.
[AGENTS.md](../AGENTS.md) has the step-by-step procedure for agents.
Some installers re-add their block when they upgrade or reinstall. When that
happens, repeat the move.
