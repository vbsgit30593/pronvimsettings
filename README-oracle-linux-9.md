# Oracle Linux 9 — Setup Guide

The **same Lua configuration** in this repo runs unchanged on Oracle Linux 9.
Neovim is cross-platform and every plugin here is OS-agnostic; only the
*prerequisite install* and a few environment notes differ from macOS. This
guide covers those differences.

Strategy: **dnf for system tools, official binaries for Neovim/Node/shfmt.**
Homebrew is deliberately avoided here — this box's brew prefix isn't the
standard `/home/linuxbrew/.linuxbrew`, so brew would compile every formula
from source and fail on missing Perl modules. dnf + the official release
binaries below install everything cleanly with no compiling.

Because this box also **builds** your C code, `compile_commands.json` is
generated locally with native paths and native gcc/clang — none of the Mac's
cross-machine path-rewriting is needed here.

---

## 1. Prerequisites

### 1a. Enable the repos that carry the tools

OL9 keeps developer tooling in EPEL and CodeReady Builder (CRB). Enable both
first, or half the `dnf install` lines below won't resolve:

```sh
# EPEL (ripgrep, fd, shellcheck, etc.)
sudo dnf install -y oracle-epel-release-el9
# CodeReady Builder equivalent on OL9 (headers/devel packages)
sudo dnf config-manager --set-enabled ol9_codeready_builder
sudo dnf makecache
```

### 1b. System tools via dnf

```sh
# Compilers, build essentials, and clang/clangd (needed by the C LSP)
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y clang clang-tools-extra llvm cmake bear

# Core CLI tools the config depends on
sudo dnf install -y git ripgrep fd-find shellcheck jq

# Python (system) + headers
sudo dnf install -y python3 python3-pip python3-devel
```

Two OL9 naming quirks to know:

- **`fd` is installed as `fd-find`** and the binary is `fd` on OL9's EPEL
  build (older Fedora/Debian shipped it as `fdfind`). Verify with
  `command -v fd`. If you only get `fdfind`, add
  `ln -s "$(command -v fdfind)" ~/.local/bin/fd` and ensure `~/.local/bin`
  is on `PATH` — Telescope's file finder calls `fd` by name.
- **`ripgrep` provides `rg`** — confirm with `command -v rg`.

### 1c. Neovim and Node — install WITHOUT Homebrew

> **Do not use `brew install neovim node` on this box.** Homebrew on Linux
> only uses fast prebuilt "bottles" when its prefix is the standard
> `/home/linuxbrew/.linuxbrew`. If yours is anywhere else (check with
> `brew --prefix` — e.g. a path under your home dir), **every formula compiles
> from source**, and those source builds fail on minimal Oracle Linux because
> of missing Perl modules (the classic
> `Can't locate ExtUtils/Command.pm` / OpenSSL build error). Skip the pain
> entirely with the official binaries below.

**Node** — official NodeSource RPM (no compiling):

```sh
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo dnf install -y nodejs
node --version
```

**Neovim** — official static tarball (no compiling, always current, needs
0.11+ which dnf's package usually isn't):

```sh
curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
nvim --version | head -1   # confirm v0.11.x or later
```

(The tarball is glibc-based; OL9's glibc is new enough to run it directly.)

**shfmt** — not in EPEL. Grab the static binary from its releases:

```sh
curl -fLo /tmp/shfmt https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.10.0_linux_amd64
sudo install -m 0755 /tmp/shfmt /usr/local/bin/shfmt
shfmt --version
```

> If you *do* want Homebrew working properly on this box for other things,
> either reinstall it to `/home/linuxbrew/.linuxbrew` (so bottles apply), or
> install the Perl modules the source builds need:
> `sudo dnf install -y perl-core perl-ExtUtils-MakeMaker perl-IPC-Cmd perl-FindBin`.
> But for this config you don't need brew at all — dnf plus the binaries
> above cover everything.

### 1d. A Nerd Font (for icons)

Fonts are a *terminal-side* concern — install the Nerd Font on whatever
machine runs your terminal emulator and select it there. If you SSH into this
OL9 box from your Mac, install the font on the **Mac** (you already did:
JetBrainsMono Nerd Font) and the glyphs render over SSH. If you sit at the OL9
box with a local desktop:

```sh
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip && rm JetBrainsMono.zip
fc-cache -f
```

---

## 2. Install the config

Identical to macOS — Neovim uses the same `~/.config/nvim` layout on Linux:

```sh
# Back up anything existing
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null

# Drop this repo so init.lua is at ~/.config/nvim/init.lua
cp -r nvim-config ~/.config/nvim

nvim   # lazy.nvim bootstraps, then Mason installs servers/tools
```

On first launch, watch `:Mason` finish, restart, then run `:checkhealth` and
resolve anything red.

### Mason on OL9: the one thing that trips people up

Mason downloads prebuilt tool binaries. Some (the LSP servers here are fine)
occasionally need a compiler/toolchain present to build native bits. The
`"Development Tools"` group + `clang`/`llvm` from step 1b cover this. If a
Mason package fails to build, its log names the missing `-devel` package —
install it with dnf and re-run `:MasonInstall <tool>`.

`telescope-fzf-native` compiles a small C library via `make`; the Development
Tools group already provides `make` and `gcc`, so it builds cleanly.

---

## 3. C projects on this box (you build here)

Because compilation happens locally, this is the *easy* path — no path
rewriting, no `.clangd` compiler override needed. Just generate the database
with native paths:

```sh
# CMake
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json .

# Make-based projects (bear installed in step 1b)
bear -- make
```

clangd (from `clang-tools-extra`) picks it up automatically via the root
markers already in the config. Native gcc/glibc headers resolve correctly
since clangd is running on the same system that compiled the code.

- Drop `.clang-format` / `.clang-tidy` at the repo root for project style —
  both are auto-detected.
- You do **not** need the `examples/dot-clangd-cross-machine` template or
  `examples/fix-compile-commands.sh` here — those exist only for copying a
  database from this box to the Mac.

### If you later navigate THIS project's code on the Mac

The reverse of the Mac guide applies: the db generated here has OL9 absolute
paths and gcc flags. To use it on the Mac, run the Mac's
`examples/fix-compile-commands.sh` (rewriting `/home/you/...` →
`/Users/you/...`) and keep the `.clangd` compiler override there. Nothing to
do on the OL9 side.

---

## 4. Python projects

Same as macOS. basedpyright + ruff are installed by Mason and read your
project's venv/config:

```sh
python3 -m venv .venv
source .venv/bin/activate     # activate BEFORE launching nvim
pip install -r requirements.txt
```

ruff line-length is set to 90 in this config (`plugins/formatting.lua` +
`plugins/lsp.lua`); a project `pyproject.toml`/`ruff.toml` line-length is
overridden by the formatter's CLI flag — delete the `ruff_format` block in
`formatting.lua` if you want project config to win.

---

## 5. Clipboard over SSH (Linux-only gotcha)

The config sets `clipboard = "unnamedplus"`. On a headless/SSH OL9 box there's
no system clipboard provider by default, so yanks won't reach your local
machine. Options:

- **Best over SSH:** use a terminal with OSC 52 support (most modern ones) —
  Neovim 0.10+ can use OSC 52 automatically for many terminals, letting yanks
  flow back to your Mac clipboard with no extra tooling.
- **Local desktop session:** install a provider so `unnamedplus` works:
  ```sh
  sudo dnf install -y xclip        # X11
  # or, on Wayland:
  sudo dnf install -y wl-clipboard
  ```
- If neither is available, Neovim still works — yanks just stay in Neovim's
  own registers. Nothing else in the config depends on the system clipboard.

---

## 6. What is identical to the Mac

Everything that isn't listed above. Same keymaps (leader = Space, `<leader>ff`
find files, `<leader>fs` live grep, `<leader>fc` grep-under-cursor, `gd`/`gR`,
etc.), same LSP/formatter/linter/DAP stack, same `:Lazy` / `:Mason` /
`:checkhealth` maintenance commands. Refer to the main `README.md` for the
full key-binding cheat sheet — it applies verbatim.

### Quick verification checklist

```sh
command -v nvim rg fd git clangd clang-format shellcheck shfmt jq
nvim --version | head -1            # 0.11+
```

Then in Neovim: `:checkhealth` (all green), open a `.c` file and confirm
`:LspInfo` shows clangd attached, open a `.py` file and confirm basedpyright +
ruff attach.
