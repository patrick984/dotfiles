# DotFiles

## Goals

1. Portable dotfiles which can be easily deployed by copy/scp.

2. Compatible with macOS and Linux.

3. Suitable for embedding minimal dev env configuration in docker containers.

4. Support for bash, zsh, tmux, vim and neovim - if available on the host.

5. Prioritise readable light-background themes in all utilities.

6. Use the existing files in the current commit as a starting point.

## Tool-specicic notes

### Neovim

1. Single file config (init.lua).

2. Avoid 3rd party plugins - i.e. use builtin LSP support.

3. (optional) Vim-Fugitive plugin for git support.

### Vim

1. Avoid 3rd party plugins - for may be necessary for LSP.

2. Use same color theme as neovim.

3. Add keybinds to make behaviour as similar to neovim as possible.

### Tmux

1. Optimise for light backgrounds.

### Zsh

1. Try to get as close to the oob experience of oh-my-zsh, without requiring it to be installed, and with minimal overhead.
