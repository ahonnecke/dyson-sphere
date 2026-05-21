# dyson-sphere

A bubblewrap-based sandbox for Claude Code (and similar LLM CLIs) so you can
hand the model `--dangerously-skip-permissions` without handing it the rest of
your machine.

The name: a Dyson sphere encloses a star and harnesses its output. The LLM is
the star.

## What it does

`wrap-claude` relaunches `claude` inside a `bwrap(1)` sandbox where:

- `$PWD` is the only host directory writable from inside.
- `~/.claude` (session/history/todos) is bound RW so resume works.
- The rest of `$HOME` is replaced by a tmpfs — no `.ssh`, `.aws`, `.env`,
  no other projects.
- `/usr` and `/etc` are read-only.
- `/tmp`, `/var`, `/run` are fresh tmpfs.
- PID, IPC, UTS namespaces are isolated.
- Network is shared by default (Claude needs `api.anthropic.com`).
- `--die-with-parent` ensures the sandbox dies with the wrapper.

Worst-case blast radius: the LLM destroys `$PWD` and your Claude session log.
Nothing else on the host is reachable for writes.

## Install

```sh
git clone <this repo> ~/src/dyson-sphere
~/src/dyson-sphere/install.sh
```

`install.sh` symlinks `wrap-claude` into `~/.local/bin/`. Make sure that's on
your `PATH`.

## Usage

The flow when an in-progress session keeps hitting permission prompts:

```
[inside claude]   /title pre-bwrap
                  /exit
[in shell]        cd <project>
                  wrap-claude "the goal — go nuts, no need to ask"
```

You can also pass through any claude flag:

```sh
wrap-claude --resume
wrap-claude -p "one-shot prompt"
```

## Environment knobs

| Var                   | Effect                                                   |
| --------------------- | -------------------------------------------------------- |
| `WRAP_CLAUDE_NO_NET=1`| Cut network entirely (only useful with a local model).   |
| `WRAP_CLAUDE_SSH=1`   | Bind `~/.ssh` RO so the sandbox can `git push` etc.      |

## Things this does NOT do

- **No CPU/memory limits.** Wrap in `systemd-run --user --scope -p MemoryMax=8G`
  if you want them.
- **No network egress filtering.** Network is binary (on/off). For
  "Anthropic only, nothing else," run a filtering HTTP proxy on the host and
  point the sandbox at it via `HTTPS_PROXY`.
- **No D-Bus filtering.** No D-Bus socket is bound, so the sandbox can't talk
  to systemd/user services at all. If you bind one back in, pair with
  `xdg-dbus-proxy`.
- **Does not block TIOCSTI keystroke injection.** `--new-session` would, but
  it breaks Claude's TUI input handling. Rely on
  `dev.tty.legacy_tiocsti_restrict=1` (default on recent kernels) or add a
  seccomp filter.

## Why not Firejail / Docker / nspawn

- **Firejail** — larger setuid attack surface, profile-based whitelist model
  fights you when project paths are unusual.
- **Docker** — needs a daemon, copies your project into an image or
  bind-mounts it with UID translation gotchas. Heavyweight for "I just want
  fewer prompts."
- **systemd-nspawn** — needs root, image-oriented.
- **Firecracker / microVM** — overkill unless you're untrusting the kernel.

`bwrap` is what Flatpak uses to sandbox every desktop app on millions of
machines. It's the right primitive for this.
