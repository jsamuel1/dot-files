# AGENTS.md

Instructions for AI agents working in this repo. Repo overview, commands, and
architecture are in [CLAUDE.md](CLAUDE.md). Shell startup is documented in
[docs/shell-startup.md](docs/shell-startup.md); read it before changing any
shell file.

## Shell startup rules

- Core files are `dots/zshenv`, `dots/zprofile`, `dots/zshrc`,
  `dots/shellenv`, `dots/bashrc`, and `dots/profile`. Don't add tool-specific
  settings to them. Each tool gets its own files in a `local/lib/` folder:
  - `<tool>.env.sh`: `PATH` and env vars, POSIX `sh`, loaded by all shells
    except `bash -c` and `sh -c`.
  - `<tool>.zsh`: aliases, functions, completions, interactive zsh only.
  - `<tool>.zsh-last`: zsh hooks that must run at the very end of `.zshrc`.
- Put files that every machine needs in `dot-files/local/lib/`. Put
  workplace files (Amazon tools such as Builder Toolbox, AIM, kiro-cmux,
  brazil, isengard, smithy-mcp) in `~/src/dot-files-amazon/local/lib/`.
- `dots/shellenv`, `dots/profile`, and every `*.env.sh` must be POSIX `sh`,
  because they run under BusyBox `ash` on Alpine Linux. No `[[ ]]`, arrays,
  `local`, `source`, `builtin`, or `${var//x/y}`.
- In `*.env.sh`, use `prepend_path`/`append_path`, never
  `export PATH=...:$PATH`.
- Don't create per-OS files. Paths need no OS check, because the helpers skip
  missing folders, and aliases should be guarded on the tool existing. Only
  settings that aren't paths and differ by OS get a check inside the tool's
  file: `case "$(uname -s)" in Darwin) ... ;; esac` in `*.env.sh` (POSIX sh
  doesn't guarantee `$OSTYPE`), or `[[ "$OSTYPE" == darwin* ]]` in `*.zsh`.

## Refactoring lines that installers added

Installers append blocks such as `# Added by AIM CLI` to the startup files.
When you find them (in `git status`, in a diff, or when asked to clean up),
move them out with this procedure.

1. **Find the blocks.** Check `git diff` for `dots/zshrc`, `dots/zshenv`,
   `dots/bashrc`, and `dots/profile`. Also read `~/.bash_profile`, which is
   machine-local and not in the repo. Each block is usually a marker comment
   plus one to a few lines. Group the lines by tool.
2. **Check what already exists.** Before writing anything:
   - Look for the tool's files in `dot-files/local/lib/` and
     `~/src/dot-files-amazon/local/lib/`. Add to an existing file instead of
     creating a second one.
   - Check whether the core files already cover the line. For example,
     `dots/zshenv` already adds `~/bin`, `~/.local/bin`, and `~/.cargo/bin`
     to `PATH`. A line that is already covered gets deleted, not moved.
3. **Pick the target file for each line:**
   - `export PATH=...`, `export VAR=...`, or `. "$HOME/.cargo/env"`-style env
     scripts go to `<tool>.env.sh`. Rewrite `PATH` lines as
     `prepend_path "<dir>"` (or `append_path` if the installer appended), and
     use `$HOME` instead of a hardcoded `/Users/<name>` path.
   - `alias`, functions, `source`/`.` of interactive helpers, completions, and
     `eval "$(tool init zsh)"` go to `<tool>.zsh`. Guard them with a check
     that the tool exists, e.g. `if (( $+commands[tool] )); then ... fi` or
     `[ -e "$HOME/.tool/lib/x.sh" ] && source ...`.
   - Anything whose comment says it must load last, or that starts a
     foreground program, goes to `<tool>.zsh-last`.
   - Pick the repo using the rule above. If you can't tell whether a tool is
     workplace or general, ask the user.
4. **Remove the block** from the core file or `~/.bash_profile`. Before
   editing `~/.bash_profile`, copy it to `~/.bash_profile.bak-<timestamp>`.
   Keep `~/.bash_profile` ending with
   `[ -r "$HOME/.shellenv" ] && . "$HOME/.shellenv"`.
5. **Link new files** into `~/.local/lib`, e.g.
   `ln -s ~/src/dot-files-amazon/local/lib/<tool>.env.sh ~/.local/lib/`.
   `settings.py` and `dot-files-amazon/symlink.sh` do the same on bootstrap.
6. **Verify:**
   - `sh -n` and `shellcheck -s sh` on every `*.env.sh` you changed;
     `zsh -n` on `*.zsh` and `*.zsh-last` files and on `dots/zshrc` /
     `dots/zshenv`; `bash -n dots/bashrc`.
   - Start shells from a clean environment and check the tool's `PATH`
     entries and variables are present exactly once:
     `env -i HOME="$HOME" PATH=/usr/bin:/bin zsh -c 'echo $PATH'`, the same
     with `zsh -lc`, `bash -lc`, and `sh -lc`.
   - `dots/zshrc` returns early without a terminal, so check aliases and
     `*.zsh` settings in a real terminal (a pty), not with `zsh -ic` from a
     tool call.
7. **Commit separately per repo** with conventional commit messages, and only
   when the user asks. `~/.bash_profile` changes aren't committed anywhere;
   mention them in your summary.
